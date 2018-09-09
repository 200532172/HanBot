return {
    id = 'AhriKornis',
    name = 'Ahri',
    riot = true,
    flag = {
      text = "Ahri by Kornis",
      color = {
        text = 0xFFEDD7E6,
        background1 = 0xFFEDBBDC,
        background2 = 0x99000000
      }
    },
    load = function()
      return player.charName == 'Ahri'
    end
}
