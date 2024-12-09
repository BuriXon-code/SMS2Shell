#!/bin/bash

# SMS prompt shell made by BuriXon-code (c) 2024
# version 1.0

CACHE_FILE="$HOME/.sms_filter_cache.txt"
COUNT=50
DELAY=5

touch "$CACHE_FILE"

function check_termux_sms_list {
	if ! command -v termux-sms-list &> /dev/null; then
		echo "ERROR: termux-sms-list not found. Make sure Termux:API is installed."
		exit 1
	fi
}

function get_filtered_messages {
	timeout 20 termux-sms-list -l "$COUNT" -t inbox | \
	jq -c '.[] | select(.body | contains(">>"))' | \
	jq -r '(.["_id"] | tostring) + "||" + .number + "||" + .body'
}

function is_message_in_cache {
	local id="$1"
	local sender="$2"
	local body="$3"
	grep -Fxq "$id||$sender||$body" "$CACHE_FILE"
}

function save_message_to_cache {
	local id="$1"
	local sender="$2"
	local body="$3"
	echo "$id||$sender||$body" >> "$CACHE_FILE"
}

function execute_command {
	local command="$1"
	local text="$( echo $@ | sed "s/TEXT\ //" )"
	local volumeNot="$( echo $@ | sed "s/VOLUME\ NOTIFICATION\ //" )"
	local volumeMus="$( echo $@ | sed "s/VOLUME\ MUSIC\ //" )"
	local volumeRin="$( echo $@ | sed "s/VOLUME\ RING\ //" )"
	local calc="$( echo $@ | sed "s/CALC\ //" | bc 2>/dev/null )"
	local sender=$SND
	local output

	case "$command" in
		TEXT\ *)
			output="$text"
		;;
		CALC\ *)
			if [[ -z "$calc" ]]; then
				output="Incorrect parameters or syntax."
			else
				output="Result: $calc"
			fi
		;;
		VOLUME\ NOTIFICATION\ *)
			if [[ "$volumeNot" =~ ^[0-9]+$ ]] && (( volumeNot >= 0 && volumeNot <= 15 )); then
				termux-volume notification $volumeNot && output="Volume set: $volumeNot/15"
			fi
		;;
		VOLUME\ MUSIC\ *)
			if [[ "$volumeMus" =~ ^[0-9]+$ ]] && (( volumeMus >= 0 && volumeMus <= 150 )); then
				termux-volume music $volumeMus && output="Volume set: $volumeMus/150"
			fi
		;;
		VOLUME\ RING\ *)
			if [[ "$volumeRin" =~ ^[0-9]+$ ]] && (( volumeRin >= 0 && volumeRin <= 15 )); then
				termux-volume ring $volumeRin && output="Volume set: $volumeRin/15"
			fi
		;;
		BATTERY)
			if [[ -d /sys/class/power_supply/battery ]]; then
				local status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
				local capacity=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
				local current=$(cat /sys/class/power_supply/battery/current_now 2>/dev/null)
				local voltage=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null)

				current=$(echo "scale=2; $current / 1000" | bc)
				voltage=$(echo "scale=2; $voltage / 1000000" | bc)

				output="Battery:\nStatus= $status\nCapacity= ${capacity}%\nCurrent= ${current}mA\nVoltage= ${voltage}V"
			else
				output="Battery information not available."
			fi
		;;
		TORCH\ ON)
			termux-torch on && output="Torch turned ON."
		;;
		TORCH\ OFF)
			termux-torch off && output="Torch turned OFF."
		;;
		UPTIME)
			output="Uptime: $(uptime -p)"
		;;
		LOCATION)
			output="$(termux-location | jq -r '.latitude, .longitude' | paste -d', ' -s | awk '{print "Location: " $1 " " $2}')"
		;;
		WHOAMI)
			output="$(whoami)"
		;;
		KILL)
			kill -9 $PPID
			output="Killing Termux..."
		;;
		KILL-SELF)
			output="Killing PID..."
		;;
		APACHE\ ON)
			apachectl &>/dev/null && output="Apache2 server ON."
		;;
		APACHE\ OFF)
			apachectl -k stop &>/dev/null && output="Apache2 server OFF."
		;;
		*)
			output="Unknown command:\n$command\nAvailable commands:\nAPACHE ON/OFF\nBATTERY\nTORCH ON/OFF\nUPTIME\nLOCATION\nWHOAMI\nTEXT <text>\nCALC <operation>\nVOLUME NOTIFICATION <0-15>\nVOLUME MUSIC <0-150>\nVOLUME RING <0-15>"
		;;
	esac

	echo -e "\n\e[38;5;46mSending SMS to: $SND\e[0m"
	echo -e "\e[38;5;46mOutput: $output\e[0m"

	if [[ -n "$SND" ]]; then
		termux-sms-send -s 0 -n "$sender" "$output"
		if [[ "$command" == "KILL-SELF" ]]; then
			kill -9 $$ &>/dev/null
		fi
	else
		echo -e "\e[38;5;196mERROR: No sender number found.\e[0m"
	fi

	echo -e "\e[38;5;45mSMS command executed\e[0m\n"
}

function parse_and_execute {
	local body="$1"
	local command=$(echo "$body" | grep -oP '(?<=>>)\s*.+')
	if [[ -n "$command" ]]; then
		command=$(echo "$command" | xargs)
		execute_command "$command"
	fi
}

function main_loop {
	while true; do
		FILTERED_MESSAGES=$(get_filtered_messages)

		while IFS="||" read -r ID SENDER BODY; do

			SND=$(echo $BODY | cut -d "|" -f 1)

			if ! is_message_in_cache "$ID" "$SENDER" "$BODY"; then
				save_message_to_cache "$ID" "$SENDER" "$BODY"
				parse_and_execute "$BODY" "$SENDER"
			fi
		done <<< "$FILTERED_MESSAGES"

	sleep "$DELAY"
	done
}

check_termux_sms_list
main_loop
