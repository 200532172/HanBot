return {
    id = 'RenektonKornis',
    name = 'Renekton',
    riot = true,
    flag = {
      text = "Renekton by Kornis",
      color = {
        text = 0xFFEDD7E6,
        background1 = 0xFFEDBBDC,
        background2 = 0x99000000
      }
    },
    load = function()
      return player.charName == 'Renekton'
    end
}
