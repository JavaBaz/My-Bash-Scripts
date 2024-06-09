#!/bin/bash

BOLD="\033[1m"
UNDERLINE="\033[4m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"
CLEAR_SCREEN="\033[2J\033[H"


read_tasks() {
  local index=0
  while IFS= read -r line; do
    tasks[$index]=$(echo "$line" | cut -d'-' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    statuses[$index]=$(echo "$line" | cut -d'-' -f2 | sed 's/^[[:space:]]*//')
    ((index++))
  done <"$1"
}



save_tasks() {
  >"$1"
  for ((i = 0; i < ${#tasks[@]}; i++)); do
    echo "${tasks[$i]} - ${statuses[$i]}" >>"$1"
  done
}


display_tasks() {
  clear
  print_status
  echo -e "${BLUE}${BOLD}${UNDERLINE}My To-Do List${RESET}"
  echo -e "${YELLOW}Total Tasks: ${#tasks[@]}${RESET}"
  echo -e "${UNDERLINE}${BOLD}All Tasks:${RESET}"
  for ((i = 0; i < ${#tasks[@]}; i++)); do
    if [ "${statuses[$i]}" = "DONE" ]; then
      status_icon="✓" # Checkmark symbol for DONE
      status_color=$GREEN
    elif [ "${statuses[$i]}" = "DELETED" ]; then
      status_icon="✗" # Cross symbol for DELETED
      status_color=$RED
    else
      status_icon="-" # Hyphen for TODO
      status_color=$YELLOW
    fi

    echo -e "$((i + 1)). ${status_color}${BOLD}${status_icon}${RESET} ${tasks[$i]}"
  done
  read -n 1 -s -r -p "Press any key to continue..."
  
}


add_task() {
  clear
  print_status
  read -p "$(echo -e ${GREEN}"Enter the new task or q to cancel: "${RESET})" new_task
  if [ "$new_task" = "q" ]; then
    echo "Task addition canceled."
  else
    tasks+=("$new_task")
    statuses+=("TODO")
    echo "Task added: TODO - $new_task"
  fi
}

change_done() {
  clear
  print_status
  read -p "Enter the task number you want to change its status to DONE: " task_number
  if ((task_number >= 1 && task_number <= ${#tasks[@]})); then
    statuses[$((task_number - 1))]="DONE"
    echo "Task marked as DONE: $task_number"
  else
    echo "Invalid task number. Please try again."
  fi
}


change_deleted() {
  clear
  print_status
  read -p "Enter the task number you want to change its status to DELETED: " task_number
  if ((task_number >= 1 && task_number <= ${#tasks[@]})); then
    statuses[$((task_number - 1))]="DELETED"
    echo "Task marked as DELETED: $task_number"
  else
    echo "Invalid task number. Please try again."
  fi
}

change_todo() {
    clear
    print_status
    read -p "Enter the task number you want to mark as TODO: " task_number
    if ((task_number >= 1 && task_number <= ${#tasks[@]})); then
      statuses[$((task_number - 1))]="TODO"
      echo "Task marked as TODO: $task_number"
    else
      echo "Invalid task number. Please try again."
    fi
}



show_todo_tasks() {
  clear
  print_status
  echo "TODO Tasks:"
  for ((i = 0; i < ${#tasks[@]}; i++)); do
    if [ "${statuses[$i]}" = "TODO" ]; then
      echo "$((i + 1)). ${statuses[$i]} - ${tasks[$i]}"
    fi
  done
  read -n 1 -s -r -p "Press any key to continue..."
}


show_done_tasks() {
  clear
  print_status
  echo "DONE Tasks:"
  for ((i = 0; i < ${#tasks[@]}; i++)); do
    if [ "${statuses[$i]}" = "DONE" ]; then
      echo "$((i + 1)). ${statuses[$i]} - ${tasks[$i]}"
    fi
  done
  read -n 1 -s -r -p "Press any key to continue..."
}


show_deleted_tasks() {
  clear
  print_status
  echo "DELETED Tasks:"
  for ((i = 0; i < ${#tasks[@]}; i++)); do
    if [ "${statuses[$i]}" = "DELETED" ]; then
      echo "$((i + 1)). ${statuses[$i]} - ${tasks[$i]}"
    fi
  done
  read -n 1 -s -r -p "Press any key to continue..."
}


search_tasks() {
  clear
  print_status
  read -p "Enter the keyword to search for: " keyword
  echo "Search results for '$keyword':"
  found=false
  for ((i = 0; i < ${#tasks[@]}; i++)); do
    if [[ "${tasks[$i]}" == *"$keyword"* ]]; then
      echo "$((i + 1)). ${statuses[$i]} - ${tasks[$i]}"
      found=true
    fi
  done
  if ! $found; then
    echo "No tasks found with the keyword '$keyword'."
  fi
  read -n 1 -s -r -p "Press any key to continue..."
}


change_task_status() {
  clear
  print_status
  select status_option in "Change to DONE" "Change to DELETED" "Change to TODO" "Go back to Main Menu"; do
    case "$REPLY" in
      1)
        change_done
        ;;
      2)
        change_deleted
        ;;
      3)
        change_todo
        ;;
      4)
        break
        ;;
      *)
        echo "Invalid option. Please try again."
        ;;
    esac
    break
  done
}



PS3=$(printf "${BOLD}Select an option:${RESET} ")

main_menu=("ShowTasks" "AddTask" "ChangeTaskStatus" "SearchTasks" "Exit")


update_status_bar() {
  local status_line="${YELLOW}                          "
  local total_tasks=${#tasks[@]}
  local done_count=0
  local deleted_count=0
  local todo_count=0

  for ((i = 0; i < ${#statuses[@]}; i++)); do
    case "${statuses[$i]}" in
      "DONE")
        ((done_count++))
        ;;
      "DELETED")
        ((deleted_count++))
        ;;
      "TODO")
        ((todo_count++))
        ;;
      *)
        ;;
    esac
  done


  local current_date_time
  current_date_time=$(date +"%Y-%m-%d %H:%M:%S")

  status_line+="Total: ${total_tasks}, Done: ${done_count}, Deleted: ${deleted_count}, TODO: ${todo_count} | Current Date/Time: ${current_date_time}${RESET}"
  echo -e "${YELLOW}${status_line}"
}

LINES=$(tput lines)

set_window (){
    tput csr 0 $(($LINES-2))
}

print_status (){
    tput cup $LINES 0;
    update_status_bar
    tput cup 0 0
}

set_window

print_menu(){
	local function_arguments=($@)

	local selected_item="$1"
	local menu_items=(${function_arguments[@]:1})
	local menu_size="${#menu_items[@]}"
  print_status

	for (( i = 0; i < $menu_size; ++i ))
	do
		if [ "$i" = "$selected_item" ]
		then
			echo "-> ${menu_items[i]}"
		else
			echo "   ${menu_items[i]}"
		fi
	done
}


run_menu(){
	local function_arguments=($@)

	local selected_item="$1"
	local menu_items=(${function_arguments[@]:1})
	local menu_size="${#menu_items[@]}"
	local menu_limit=$((menu_size - 1))

	clear
	print_menu "$selected_item" "${menu_items[@]}"
	
	while read -rsn1 input
	do
		case "$input"
		in
			$'\x1B')  
				read -rsn1 -t 0.1 input
				if [ "$input" = "[" ]
				then
					read -rsn1 -t 0.1 input
					case "$input"
					in
						A)  # Up Arrow
							if [ "$selected_item" -ge 1 ]
							then
								selected_item=$((selected_item - 1))
								clear
								print_menu "$selected_item" "${menu_items[@]}"
							fi
							;;
						B) 
							if [ "$selected_item" -lt "$menu_limit" ]
							then
								selected_item=$((selected_item + 1))
								clear
								print_menu "$selected_item" "${menu_items[@]}"
							fi
							;;
					esac
				fi
				read -rsn5 -t 0.1  
				;;
			"") 
				return "$selected_item"
				;;
		esac
	done
}

show_main_menu() {
  local selected_item=0
  local menu_items=("Show-Tasks" "Add-Task" "Change-Task-Status" "Search-Tasks" "Exit")

  while true; do
    clear
    update_status_bar
    run_menu "$selected_item" "${menu_items[@]}"
    local menu_result="$?"

    case "$menu_result" in
      0)
        show_tasks_submenu
        ;;
      1)
        add_task
        ;;
      2)
        change_task_status
        ;;
      3)
        search_tasks
        ;;
      4)
        save_tasks "$file"
        clear
        echo "Exiting..."
        exit 0
        ;;
    esac
  done
}


show_tasks_submenu(){
  local selected_item=0
  local submenu_items=("All" "Done" "Deleted" "TODO" "Go-back-to-Main-Menu")

  while true; do
    clear
    update_status_bar
    run_menu "$selected_item" "${submenu_items[@]}"
    local submenu_result="$?"

    case "$submenu_result" in
      0)
        display_tasks
        ;;
      1)
        show_done_tasks
        ;;
      2)
        show_deleted_tasks
        ;;
      3)
        show_todo_tasks
        ;;
      4)
        break
        ;;
    esac
  done
}

file="myToDoList.txt"

if [ ! -f "$file" ]; then
  echo "Creating new file: $file"
  touch "$file"
fi


read_tasks "$file"

show_main_menu