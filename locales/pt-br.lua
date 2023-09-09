local Translations = {
error = {
    you_dont_have_the_ingredients_to_make_this = "você não possui os ingredientes para fazer isso!",
    something_went_wrong = 'algo deu errado!',
    you_dont_have_that_much_on_you = "Você não tem isso tudo com você.",
    you_dont_have_an_item_on_you = "Você não tem um item com você",
    must_not_be_a_negative_value = 'não deve ser um valor negativo.',
},
success = {
    you_made_some_moonshine = 'você fez um pouco de moonshine',
    you_sold = 'Você vendeu  %{amount} por $ %{totalcash}',
},
primary = {
    moonshine_destroyed = 'moonshine destruído!',
},
menu = {
    close_menu = 'Fechar menu',
    price = ' (preço $',
    enter_the_number_of_1pc = "Digite o número de 1 pc / ${price} $",
    brew = 'Fazer [J]',
    destroy = 'Destruir [J]',
    moonshine = '| Moonshine |',
    make_moonshine = 'Fazer Moonshine',
    sell_moonshine = 'vender moonshine',
},
commands = {
    var = 'o texto vai aqui',
},
progressbar = {
    var = 'o texto vai aqui',
},
blip = {
    moonshine_vendor = 'Vendedor de Moonshine',
},
text = {
    xsugar_1xWater_and_1xcorn = '1 x Açúcar 1 x Água e 1 x Milho',
    sell = 'vender',
}
}

if GetConvar('rsg_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
