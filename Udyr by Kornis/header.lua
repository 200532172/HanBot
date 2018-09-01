return {
    id = 'UdyrKornis',
    name = 'Udyr',
    riot = true,
    flag = {
      text = "Udyr by Kornis",
      color = {
        text = 0xFFEDD7E6,
        background1 = 0xFFFF69B4,
        background2 = 0x59000000,
      }
    },
    load = function()
      return player.charName == 'Udyr'
    end
}
