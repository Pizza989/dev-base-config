#!/usr/bin/env nu
# ~/.config/yazelix/nushell/open_file.nu

# Open a file in Helix, integrating with Yazi and Zellij
source zellij_utils.nu  # Import Zellij helpers

def is_hx_running [list_clients_output: string] {
    let cmd = $list_clients_output | str trim | str downcase
    
    # Split the command into parts
    let parts = $cmd | split row " "
    
    # Check if any part ends with 'hx' or is 'hx'
    let has_hx = ($parts | any {|part| $part | str ends-with "/hx"})
    let is_hx = ($parts | any {|part| $part == "hx"})
    let has_or_is_hx = $has_hx or $is_hx
    
    # Find the position of 'hx' in the parts
    let hx_positions = ($parts | enumerate | where {|x| ($x.item == "hx" or ($x.item | str ends-with "/hx"))} | get index)
    
    # Check if 'hx' is the first part or right after a path
    let is_hx_at_start = if ($hx_positions | is-empty) {
        false
    } else {
        let hx_position = $hx_positions.0
        $hx_position == 0 or ($hx_position > 0 and ($parts | get ($hx_position - 1) | str ends-with "/"))
    }
    
    let result = $has_or_is_hx and $is_hx_at_start
    
    # Debug info
    print $"input: list_clients_output = ($list_clients_output)"
    print $"treated input: cmd = ($cmd)"
    print $"  parts: ($parts)"
    print $"  has_hx: ($has_hx)"
    print $"  is_hx: ($is_hx)"
    print $"  has_or_is_hx: ($has_or_is_hx)"
    print $"  hx_positions: ($hx_positions)"
    print $"  is_hx_at_start: ($is_hx_at_start)"
    print $"  Final result: ($result)"
    print ""
    
    $result
}

def main [file_path: path] {
    print $"DEBUG: file_path received: ($file_path), type: ($file_path | path type)"
    if not ($file_path | path exists) {
        print $"Error: File path ($file_path) does not exist"
        return
    }

    # Capture YAZI_ID from Yazi’s pane
    let yazi_id = $env.YAZI_ID
    if ($yazi_id | is-empty) {
        print "Warning: YAZI_ID not set in this environment. Yazi navigation may fail."
    }

    # Move focus and check Helix status
    find_helix
    let running_command = (get_running_command)

    # Open file based on whether Helix is already running
    if (is_hx_running $running_command) {
        open_in_existing_helix $file_path
    } else {
        open_new_helix_pane $file_path $yazi_id
    }
}
