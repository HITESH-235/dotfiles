import os
import glob

themes_dir = "/home/hit235/.config/waybar/style/*.css"
count = 0

for filepath in glob.glob(themes_dir):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Check if we need to add custom-volume
    if "#custom-volume," not in content and "#pulseaudio," in content:
        # Inject #custom-volume, after #pulseaudio,
        new_content = content.replace("#pulseaudio,", "#pulseaudio,\n#custom-volume,")
        
        if new_content != content:
            with open(filepath, 'w') as f:
                f.write(new_content)
            count += 1

print(f"Updated {count} theme files.")
