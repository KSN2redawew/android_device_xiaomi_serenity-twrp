#!/system/bin/sh

load_panel()
   {
   	insmod /lib/modules/sensorhub.ko
   	insmod /lib/modules/gpio.ko
   	insmod /lib/modules/focaltech_ft8057_spi_ts.ko
    insmod /lib/modules/sc27xx-vibra.ko
    insmod /lib/modules/sc27xx_adc.ko
   }

load_panel
wait 1
setprop modules.loaded 1
exit 0