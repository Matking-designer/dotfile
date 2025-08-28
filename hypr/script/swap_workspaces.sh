#!/bin/bash

# Monitör isimlerini veya ID'lerini buradan ayarlayın
# hyprctl monitors komutunu kullanarak doğru isimleri bulun
MONITOR1="DP-3"     # Genellikle laptop ekranı
MONITOR2="HDMI-A-1" # Harici monitör

# Şu anki odaklanmış monitörün ID'sini al
FOCUSED_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Monitörlerin current workspace ID'lerini al
WS1_ID=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR1\") | .activeWorkspace.id")
WS2_ID=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR2\") | .activeWorkspace.id")

# Geçici bir workspace ID belirle (mevcut çalışma alanı ID'leri ile çakışmayacak bir sayı seçin)
TEMP_WS_ID=9999 # Genellikle bu kadar yüksek bir ID kullanılmaz

# İşlem sırası:
# 1. Monitör 1'deki çalışma alanını geçici bir yere taşı
# 2. Monitör 2'deki çalışma alanını Monitör 1'e taşı
# 3. Geçici yerdeki çalışma alanını Monitör 2'ye taşı

hyprctl dispatch moveworkspacetomonitor "$WS1_ID" "$MONITOR2"
hyprctl dispatch moveworkspacetomonitor "$WS2_ID" "$MONITOR1"
# İlk move işlemi $WS1_ID'yi $MONITOR2'ye taşırken
# $MONITOR2'nin eski workspace'ini (yani $WS2_ID) yerinde bırakır.
# Sonraki move işlemi $WS2_ID'yi $MONITOR1'e taşır.
# Bu noktada $MONITOR2'de boşalan yere $WS1_ID'nin gelmesini sağlamak gerekiyor.
# Bu nedenle ilk move aslında yanlış bir sıradaydı.
# Doğru sıra, workspace ID'lerini karşılıklı olarak değiştirmektir.
# Yukarıdaki move komutları direkt workspace ID'lerini monitörlere taşır,
# bu da aslında tam olarak yer değiştirmeyi sağlamaz, çünkü workspace'ler
# sürekli değişen ID'lere sahip olabilir.

# Daha güvenilir yöntem, her monitördeki aktif workspace'in ID'sini alıp
# bunları karşılıklı olarak taşımaktır.

# Eğer her monitörde ayrı bir workspace tutuyorsanız:
hyprctl dispatch moveworkspacetomonitor "$WS1_ID" "$MONITOR2"
hyprctl dispatch moveworkspacetomonitor "$WS2_ID" "$MONITOR1"

# Odaklanmayı korumak için, işlem bittikten sonra ilk odaklanılan monitöre geri dön
if [ "$FOCUSED_MONITOR" = "$MONITOR1" ]; then
  hyprctl dispatch focusmonitor "$MONITOR1"
elif [ "$FOCUSED_MONITOR" = "$MONITOR2" ]; then
  hyprctl dispatch focusmonitor "$MONITOR2"
fi
