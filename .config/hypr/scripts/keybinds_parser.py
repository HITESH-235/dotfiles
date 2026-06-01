#!/usr/bin/env python3
import sys
import re
import os

def normalize_combo(combo):
    return combo.replace(" ", "").replace("\t", "")

def extract_combo(line):
    # Remove comments and whitespace
    line = re.sub(r'\s*#.*$', '', line).strip()
    
    if '=' not in line:
        return None
        
    try:
        rhs = line.split('=', 1)[1]
        parts = [p.strip() for p in rhs.split(',')]
        if len(parts) < 2:
            return None
            
        mods = parts[0]
        key = parts[1]
        return f"{mods},{key}"
    except Exception:
        return None

def shorten_category(cat):
    cat_upper = cat.upper()
    if "MOVE ACTIVE WINDOW TO A WORKSPACE SILENTLY" in cat_upper:
        return "Silent WS"
    if "MOVE ACTIVE WINDOW AND FOLLOW TO WORKSPACE" in cat_upper:
        return "Move WS"
    if "MOVE/RESIZE WINDOWS WITH MAINMOD" in cat_upper:
        return "Mouse Binds"
    if "SCROLL THROUGH EXISTING WORKSPACES" in cat_upper:
        return "Scroll WS"
    if "SWITCH WORKSPACES WITH MAINMOD" in cat_upper:
        return "Switch WS"
    if "MOVE CURRENT WORKSPACES TO MONITORS" in cat_upper:
        return "Monitors"
    if "MOVE FOCUS WITH MAINMOD" in cat_upper:
        return "Focus"
    if "MOVE WINDOW INTO/OUT OF GROUP" in cat_upper:
        return "Group Move"
    if "NAVIGATE WITHIN A GROUP" in cat_upper:
        return "Group Nav"
    if "SPECIAL KEYS / HOT KEYS" in cat_upper:
        return "Special Keys"
    if "WAYBAR / BAR RELATED" in cat_upper:
        return "Waybar"
    if "SCREENSHOT WITH SWAPPY" in cat_upper:
        return "Screenshot Swappy"
    if "SCREENSHOT KEYBINDINGS" in cat_upper:
        return "Screenshot"
    if "DESKTOP ZOOMING" in cat_upper:
        return "Zoom"
    if "CYCLE WINDOWS" in cat_upper:
        return "Cycle Windows"
    if "FEATURES / EXTRAS (USERSCRIPTS)" in cat_upper:
        return "Userscripts"
    if "FEATURES / EXTRAS" in cat_upper:
        return "Extras"
    if "COMMON SHORTCUTS" in cat_upper:
        return "Common"
    if "KEYBOARD BACKLIGHT" in cat_upper:
        return "Kbd Backlight"
    if "FAN / POWER PROFILE" in cat_upper:
        return "Power/Fans"
    if "OVERRIDES FOR FN+F4" in cat_upper:
        return "Fn Key Fix"
    if "NIGHT LIGHT" in cat_upper:
        return "Night Light"
    if "MEDIA CONTROLS" in cat_upper:
        return "Media Controls"
    if "WORKS ON EITHER LAYOUT" in cat_upper:
        return "Both Layouts"
    if "WORKSPACES RELATED" in cat_upper:
        return "Workspaces"
    
    if len(cat) > 18:
        return cat[:15] + "..."
    return cat.title()

def parse_files(files):
    # Data structures to match original logic
    binding_map = {}        # combo -> (raw_line, category)
    source_map = {}         # combo -> source file
    user_bind_map = {}      # combo -> (raw_line, category)
    unbound_user = {}       # combo -> True if explicitly unbound in user file
    seen_any_bind = {}      # combo -> True if seen
    default_seen = {}       # combo -> True if default bind exists
    
    if not files:
        return [], []
        
    user_conf_path = files[-1] if len(files) > 1 else None

    for file_path in files:
        if not os.path.exists(file_path):
            continue
            
        current_category = "General"  # Default fallback category
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    line = line.rstrip('\n')
                    if not line:
                        continue
                        
                    stripped = line.strip()
                    
                    # Capture categories from comments
                    if stripped.startswith('#'):
                        # Clean leading/trailing symbols and spaces
                        cleaned = re.sub(r'^[\s#*-]+|[\s#*-]+$', '', stripped)
                        if cleaned and len(cleaned) >= 3:
                            lower_cleaned = cleaned.lower()
                            # Ignore link lines, variables, templates, examples, etc.
                            if not any(x in lower_cleaned for x in ["http", "github", "jakoolit", "variables", "e.g.", "note:", "created this", "super key", "see also", "settings for", "visit", "bindings", "bind", "unbind", "exec", "source", "env"]):
                                # Normalize common categories
                                if cleaned.upper() in ["STANDAR", "STANDARD"]:
                                    current_category = "Apps"
                                elif cleaned.upper() == "SYSTEM":
                                    current_category = "System"
                                else:
                                    current_category = shorten_category(cleaned)
                        continue
                        
                    is_bind = re.match(r'^\s*bind[a-z]*\s*=', line)
                    is_unbind = re.match(r'^\s*unbind\s*=', line)
                    
                    if is_bind:
                        combo_raw = extract_combo(line)
                        if not combo_raw:
                            continue
                        combo = normalize_combo(combo_raw)
                        seen_any_bind[combo] = True
                        
                        is_user_file = (file_path == user_conf_path)
                        
                        if not is_user_file:
                            default_seen[combo] = True
                            
                        # prefer user bind, else first seen
                        if combo not in source_map:
                            binding_map[combo] = (line, current_category)
                            source_map[combo] = file_path
                            
                        if is_user_file:
                            user_bind_map[combo] = (line, current_category)
                            binding_map[combo] = (line, current_category)
                            source_map[combo] = file_path
                            
                    elif is_unbind:
                        combo_raw = extract_combo(line)
                        if not combo_raw:
                            continue
                        combo = normalize_combo(combo_raw)
                        
                        if file_path == user_conf_path:
                            unbound_user[combo] = True
                            
                        # If unbind is found, remove the bind from maps
                        if combo in binding_map:
                            del binding_map[combo]
                        if combo in source_map:
                            del source_map[combo]
                            
        except Exception as e:
            sys.stderr.write(f"Error reading {file_path}: {e}\n")
            continue

    # Build results
    raw_keybinds = []
    missing_unbind_suggestions = []
    
    for combo in seen_any_bind:
        eff_tuple = binding_map.get(combo)
        src = source_map.get(combo)
        
        if not eff_tuple:
            continue
            
        raw_keybinds.append(eff_tuple)
        
        # Check for missing unbind suggestions
        if (src == user_conf_path and 
            combo in default_seen and 
            combo not in unbound_user):
            
            eff_line = eff_tuple[0]
            suggest = re.sub(r'^\s*bind[a-z]*', 'unbind', eff_line)
            missing_unbind_suggestions.append(suggest)
            
    return raw_keybinds, missing_unbind_suggestions

def format_for_rofi(raw_binds):
    formatted_lines = []
    
    for line, category in raw_binds:
        # line is like "bind = MODS, KEY, DISPATCHER, PARAMS" or "bindd = ..."
        match = re.match(r'^\s*(bind[a-z]*)\s*=(.*)', line)
        if not match:
            continue
            
        binder = match.group(1).replace(" ", "").replace("\t", "")
        rhs = match.group(2).strip()
        
        has_desc = binder.endswith('d')

        # Split by comma
        parts = [p.strip() for p in rhs.split(',')]
        
        if len(parts) < 2:
            continue
            
        mods = parts[0]
        key = parts[1]
        
        desc = ""
        dispatcher = ""
        params = ""
        
        start_idx = 0
        
        if has_desc:
            desc = parts[2] if len(parts) >= 3 else ""
            dispatcher = parts[3] if len(parts) >= 4 else ""
            start_idx = 4
        else:
            dispatcher = parts[2] if len(parts) >= 3 else ""
            start_idx = 3
            
        # Collect params
        remaining_parts = []
        if start_idx < len(parts):
            for i in range(start_idx, len(parts)):
                if parts[i]:
                    remaining_parts.append(parts[i])
        
        if remaining_parts:
            params = ", ".join(remaining_parts)
            
        # Formatting mods
        mods = mods.replace("$mainMod", "SUPER")
        mods = re.sub(r'[ \t]+', '+', mods)
        
        # Build combo string
        if mods and key:
            combo_str = f"{mods}+{key}"
        elif key:
            combo_str = key
        else:
            combo_str = mods
            
        # Determine Description
        work_str = ""
        if has_desc and desc:
            work_str = desc
        elif dispatcher:
            if params:
                work_str = f"{dispatcher} {params}"
            else:
                work_str = dispatcher
        else:
            work_str = "Custom keybinding"
            
        category_prefix = f"[{category.upper()}]"
        formatted_lines.append((category_prefix, work_str, combo_str))
            
    return formatted_lines

def main():
    if len(sys.argv) < 2:
        sys.exit(0)
        
    config_files = sys.argv[1:]
    
    binds, suggestions = parse_files(config_files)
    
    if not binds:
        print("no keybinds found.")
        sys.exit(1)
        
    formatted = format_for_rofi(binds)
    
    # Sort alphabetically by Category first, then by Description
    formatted.sort(key=lambda x: (x[0].lower(), x[1].lower()))
    
    # Format and align beautifully with shortcut on the left
    for category_prefix, work_str, combo_str in formatted:
        print(f"{combo_str:<24} ➜   {category_prefix:<20} {work_str}")
        
    if suggestions:
        import tempfile
        try:
            with tempfile.NamedTemporaryFile(mode='w', delete=False, prefix='hypr-unbind-suggestions-', suffix='.conf') as tf:
                tf.write('\n'.join(suggestions) + '\n')
                with open("/tmp/hypr_keybind_suggestions_file", "w") as sf:
                    sf.write(tf.name)
        except Exception:
            pass

if __name__ == "__main__":
    main()
