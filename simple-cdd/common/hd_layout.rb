Layout_HD_Server=<<EOF
d-i partman-auto/expert_recipe string \
condpart :: \
512 512 512 ext3 \
$primary{ } $bootable{ } \
method{ format } format{ } \
label { demarrage } \
use_filesystem{ } filesystem{ ext2 } \
mountpoint{ /boot } \
. \
2048 10240 10240 ext3 \
method{ format } format{ } \
label { premier_systeme } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ / } \
. \
2048 10240 10240 ext3 \
method{ format } format{ } \
use_filesystem{ } filesystem{ ext3 } \
label { deuxieme_systeme } \
mountpoint{ /system2 } \
. \
1024 10240 300% linux-swap \
method{ swap } format{ } \
. \
512 5120 5120 ext3 \
method{ format } format{ } \
label { home } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ /home } \
. \
512 4096 10000000 ext3 \
method{ format } format{ } \
label { opt } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ /opt } \
.

EOF

# As ALIX is on a CF-Flash we use ext2 and not ext3 !
Layout_Alix_Board=<<EOF  
d-i partman-auto/expert_recipe string \
condpart :: \
32 32 32 ext3 \
$primary{ } $bootable{ } \
method{ format } format{ } \
label { demarrage } \
use_filesystem{ } filesystem{ ext2 } \
mountpoint{ /boot } \
. \
2048 10240 10240 ext2 \
method{ format } format{ } \
label { ROOT } \
use_filesystem{ } filesystem{ ext2 } \
mountpoint{ / } \
. \
512 1024 300% linux-swap \
method{ swap } format{ } \
. \

EOF
          
Layout_Server_Board=<<EOF  
d-i partman-auto/expert_recipe string \
condpart :: \
32 32 32 ext3 \
$primary{ } $bootable{ } \
method{ format } format{ } \
label { demarrage } \
use_filesystem{ } filesystem{ ext2 } \
mountpoint{ /boot } \
. \
512 2048 300% linux-swap \
method{ swap } format{ } \
. \
2048 10240 10240 ext3 \
method{ format } format{ } \
label { ROOT } \
use_filesystem{ } filesystem{ ext2 } \
mountpoint{ / } \
. \

EOF