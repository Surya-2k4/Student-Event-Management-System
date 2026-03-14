import os
import glob

files_to_fix = [
    r'lib\screens\view_events.dart',
    r'lib\screens\user_screen.dart',
    r'lib\screens\report.dart',
    r'lib\screens\register_screen.dart',
    r'lib\screens\login_screen.dart',
    r'lib\screens\event_registration.dart',
    r'lib\main.dart'
]

for file_path in files_to_fix:
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        continue
        
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    new_lines = []
    in_upstream = False
    in_stashed = False
    
    for line in lines:
        if line.startswith('<<<<<<< Updated upstream'):
            in_upstream = True
            continue
        elif line.startswith('======='):
            in_upstream = False
            in_stashed = True
            continue
        elif line.startswith('>>>>>>> Stashed changes'):
            in_stashed = False
            continue
            
        if not in_upstream:
            new_lines.append(line)
            
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

    print(f"Fixed {file_path}")
