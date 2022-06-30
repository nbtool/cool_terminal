#!/bin/bash

# 绘制 terminal
function create_terminal(){
    SCREEN_W=$1
    SCREEN_H=$2

    if (( $SCREEN_H == 1080)) && (($SCREEN_W == 1920)) ;then 
        X_BOARD=15          #窗口与窗口之间的横向补偿（由于存在精度误差，该值是经验值）
        Y_BOARD=15

        LEFT_OFFSET=$3
        UP_OFFSET=$4

        H=50   #1080
        W=189  #1920

        win1_pos_x=$((LEFT_OFFSET+X_BOARD))
        win1_pos_y=$((UP_OFFSET+Y_BOARD))
        win1_size_w=$W
        win1_size_h=$((H*2/3))

        win2_pos_x=$win1_pos_x
        win2_pos_y=$((win1_pos_y + SCREEN_H*2/3 + Y_BOARD -22))
        win2_size_w=$((W/2-1))
        win2_size_h=$((H/3))

        win3_pos_x=$((win1_pos_x+SCREEN_W/2-8))
        win3_pos_y=$((win2_pos_y))
        win3_size_w=$win2_size_w
        win3_size_h=$((win2_size_h-2))

        xfce4-terminal --geometry $win1_size_w'x'$win1_size_h'+'$win1_pos_x'+'$win1_pos_y -Tcode -e'bash -c "vim ; bash"'
        xfce4-terminal --geometry $win2_size_w'x'$win2_size_h'+'$win2_pos_x'+'$win2_pos_y -Tcmd -e'bash -c "screenfetch ; bash"'
        xfce4-terminal --geometry $win3_size_w'x'$win3_size_h'+'$win3_pos_x'+'$win3_pos_y -Tlog -e'bash -c "xdotool key ctrl+shift+t; bash"'

        echo $win1_size_w'x'$win1_size_h'+'$win1_pos_x'+'$win1_pos_y
        echo $win2_size_w'x'$win2_size_h'+'$win2_pos_x'+'$win2_pos_y
        echo $win3_size_w'x'$win3_size_h'+'$win3_pos_x'+'$win3_pos_y
    elif (( $SCREEN_H == 1024)) && (($SCREEN_W == 1280)) ;then 
        X_BOARD=30          #窗口与窗口之间的横向补偿（由于存在精度误差，该值是经验值）
        Y_BOARD=30

        LEFT_OFFSET=$3
        UP_OFFSET=$4

        H=48 #56   #1024
        W=129 #142  #1280

        win1_pos_x=$((LEFT_OFFSET+X_BOARD))
        win1_pos_y=$((UP_OFFSET+Y_BOARD))
        win1_size_w=$((W/2-4))
        win1_size_h=$((H-2))

        win2_pos_x=$((win1_pos_x + SCREEN_W/2 + X_BOARD - 48))
        win2_pos_y=$win1_pos_y
        win2_size_w=$win1_size_w
        win2_size_h=$((win1_size_h/2))

        win3_pos_x=$win2_pos_x
        win3_pos_y=$((win1_pos_y + SCREEN_H/2 + Y_BOARD - 40))
        win3_size_w=$win2_size_w
        win3_size_h=$((win2_size_h-1))

   
        # xwininfo
        xfce4-terminal --geometry $win1_size_w'x'$win1_size_h'+'$win1_pos_x'+'$win1_pos_y -Tsys 
        xfce4-terminal --geometry $win2_size_w'x'$win2_size_h'+'$win2_pos_x'+'$win2_pos_y -Tmem -e'bash -c "curl \"wttr.in/HangZhou?0\";bash"'
        xfce4-terminal --geometry $win3_size_w'x'$win3_size_h'+'$win3_pos_x'+'$win3_pos_y -Tinfo -e'bash -c "sampler -c runchart.yml;bash"'
    fi
}


# 获取鼠标位置
mouse_pos_x=`xdotool getmouselocation | sed "s:x\:\([0-9]*\) y\:\([0-9]*\) .*:\1:g"`
mouse_pos_y=`xdotool getmouselocation | sed "s:x\:\([0-9]*\) y\:\([0-9]*\) .*:\2:g"`

echo "mouse_pos_x = "$mouse_pos_x
echo "mouse_pos_y = "$mouse_pos_y


# 通过下面逻辑，可以将所有屏幕的大小和位置全部算出来
# screen [x, y, x_start, y_start, x_end, y_end]
x_index=0
s_index=0
for x in `xrandr | grep " connected" | sed "s:.* connected.* \([0-9]*\)x\([0-9]*\)+\([0-9]*\)+\([0-9]*\).*:\1 \2 \3 \4:g"`
do
    echo $x
    screen[$s_index]=$x
    let x_index++
    let s_index++
    if [ $((x_index % 4)) -eq 0 ];then
        screen[$((s_index+0))]=$((screen[$((s_index-4))]+screen[$((s_index-2))]));
        screen[$((s_index+1))]=$((screen[$((s_index-3))]+screen[$((s_index-1))]));
        let s_index+=2
    fi
done

echo ${screen[@]}

# 计算坐标 (x,y) 是否在某个屏幕中 (x_start,y_start,x_end,y_end)
function point_in_screen(){
    local x=$1
    local y=$2
    local x_start=$3
    local y_start=$4
    local x_end=$5
    local y_end=$6

    if (($x >= $x_start)) && (($x <= $x_end)) && (($y >= $y_start)) && (($y <= $y_end)) ; then
        return 1
    else
        return 0
    fi
}

screen_num=$((s_index/6))
index=0
while [ $index -le $screen_num ]
do
    point_in_screen $mouse_pos_x $mouse_pos_y ${screen[$((index*6+2))]} ${screen[$((index*6+3))]} ${screen[$((index*6+4))]} ${screen[$((index*6+5))]}
    if [ $? == 1 ];then
        echo 'the point in scree '$index
        create_terminal ${screen[$((index*6))]} ${screen[$((index*6+1))]} ${screen[$((index*6+2))]} ${screen[$((index*6+3))]}
        break
    fi
    let index++
done


