import subprocess
import json

def get(cmd):
    try:
        return json.loads(subprocess.check_output(f"hyprctl {cmd} -j", shell=True))
    except:
        return []

# 1. Verileri topla
monitors = get("monitors")
clients = get("clients")

if len(monitors) < 2:
    print("En az iki monitör gerekli!")
    exit()

# 2. Koordinata göre monitörleri bul (En küçük x = En sol)
monitors.sort(key=lambda m: m['x'])
m_left = monitors[0]
m_right = monitors[1]

# Aktif workspace ID'lerini al
ws_l = m_left['activeWorkspace']['id']
ws_r = m_right['activeWorkspace']['id']

# 3. Pencereleri ayıkla (Special ve diğer monitörleri filtrele)
# Sadece o monitörde VE o workspace'de olan pencereleri al
left_windows = [c['address'] for c in clients if c['monitor'] == m_left['id'] and c['workspace']['id'] == ws_l and not c['workspace']['name'].startswith("special")]
right_windows = [c['address'] for c in clients if c['monitor'] == m_right['id'] and c['workspace']['id'] == ws_r and not c['workspace']['name'].startswith("special")]

batch = []

# ADIM A: Solu 99'a çek
for addr in left_windows:
    batch.append(f"dispatch movetoworkspacesilent 99,address:{addr}")

# ADIM B: Sağı Sola çek
for addr in right_windows:
    batch.append(f"dispatch movetoworkspacesilent {ws_l},address:{addr}")

# ADIM C: 99'dakileri (Eski Sol) Sağa çek
for addr in left_windows:
    batch.append(f"dispatch movetoworkspacesilent {ws_r},address:{addr}")

# 4. Hepsini tek pakette gönder
if batch:
    command = f"hyprctl --batch '{';'.join(batch)}'"
    subprocess.run(command, shell=True)
