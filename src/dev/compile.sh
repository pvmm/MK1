#!/bin/sh

export MK1_HOME=/home/pedro_/Sync/Softwares/gnu_linux/MK1
export Z88DK=$MK1_HOME/env/z88dk10
export PATH=$Z88DK/bin:$PATH
export ZCCCFG=$MK1_HOME/env/z88dk10/lib/config/
GAME=dogmole
LABEL=$(echo $GAME | tr '[:lower:]' '[:upper:]') 

winetest()
{
    _=$(wine --help) # we just want the error code
    [ $? -eq 127 ] && echo "Wine not found. Please install it." && exit 1
}

compile()
{
    echo -e "\e[32mCompilando guego\e[0m"
    zcc +zx -vn mk1.c -o $GAME.bin -lsplib2_mk2.lib -zorg=24000 > /dev/null
    winetest
    ../utils/printsize $GAME.bin
    ../utils/printsize scripts.bin

    echo -e "\e[32mConstruyendo cinta\e[0m"
    ../utils/bas2tap -a10 -s$LABEL loader/loader.bas loader.tap > /dev/null
    ../utils/bin2tap -o screen.tap -a 16384 loading.bin > /dev/null
    ../utils/bin2tap -o main.tap -a 24000 $GAME.bin > /dev/null
    cat loader.tap screen.tap main.tap 1> $GAME.tap 2> /dev/null
}

clean()
{
    echo -e "\e[32mLimpiando\e[0m"
    rm loader.tap > /dev/null
    rm screen.tap > /dev/null
    rm main.tap > /dev/null
    rm ../gfx/*.scr > /dev/null
    rm *.bin > /dev/null
    rm ../script/msc.h
    rm ../script/msc-config.h
    rm ../script/scripts.bin
    rm my/msc.h
    rm my/msc-config.h
}

script()
{
    cd ../script
    if [ -f $GAME.spt ]
    then
        echo -e "\e[32mCompilando script\e[0m"
        winetest
        ../utils/msc3_mk1 $GAME.spt 30 > /dev/null
        cp msc.h ../dev/my > /dev/null
        cp msc-config.h ../dev/my > /dev/null
        cp scripts.bin ../dev/ > /dev/null
    fi
    cd ../dev
}

assets()
{
    echo -e "\e[32mConvirtiendo mapa\e[0m"
    wine ../utils/mapcnv.exe ../map/mapa.map assets/mapa.h 6 5 15 10 15 packed > /dev/null

    echo -e "\e[32mConvirtiendo enemigos/hotspots\e[0m"
    wine ../utils/ene2h.exe ../enems/enems.ene assets/enems.h

    echo -e "\e[32mImportando GFX\e[0m"
    wine ../utils/ts2bin.exe ../gfx/font.png ../gfx/work.png tileset.bin 7 > /dev/null

    wine ../utils/sprcnv.exe ../gfx/sprites.png assets/sprites.h > /dev/null

    wine ../utils/sprcnvbin.exe ../gfx/sprites_extra.png sprites_extra.bin 1 > /dev/null
    wine ../utils/sprcnvbin8.exe ../gfx/sprites_bullet.png sprites_bullet.bin 1 > /dev/null

    wine ../utils/png2scr.exe ../gfx/title.png ../gfx/title.scr > /dev/null
    wine ../utils/png2scr.exe ../gfx/marco.png ../gfx/marco.scr > /dev/null
    wine ../utils/png2scr.exe ../gfx/ending.png ../gfx/ending.scr > /dev/null
    wine ../utils/png2scr.exe ../gfx/loading.png loading.bin > /dev/null
    ../utils/apultra ../gfx/title.scr title.bin > /dev/null
    ../utils/apultra ../gfx/marco.scr marco.bin > /dev/null
    ../utils/apultra ../gfx/ending.scr ending.bin > /dev/null
}

case "$1" in
    all)
        script
        assets
        compile
        clean
        ;;
    justcompile)
        compile
        clean
        ;;
    clean)
        clean
        ;;
    justscripts)
        script
        ;;
    justassets)
        script
        assets
        ;;
    noclean)
        script
        assets
        compile
        ;;
    *)
        echo "compile.sh help|justcompile|clean|justscripts|justassets|noclean"
        exit 3
        ;;
esac

