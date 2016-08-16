

require "rexml/document" # подключаем парсер
require "date" # будем использовать операции с данными

current_path = File.dirname(__FILE__)
file_name = current_path + "/my_expenses.xml" #находим файл в той же папке

abort "Нет файла с данными" unless File.exist?(file_name) #досрочно завершаемся, если он не найден

file = File.new(file_name)  # открываем файл

doc = REXML::Document.new(file)
# REXML::Document.new(file) - создает новый обьект парсера XML из файла file 
# в doc лежит обьект - XML дерево

amount_by_day = Hash.new # пустой хеш, куда будем складывать трату за каждый день

doc.elements.each("expenses/expense") do |item|
# xml.elementseach("путь_к_тегам") do |элемент| цикл по всем елементам XML дерева, лежащим по заданному пути
# XPath - формат адресации расположения элементов внутри XML докумета
	loss_sum = item.attributes["amount"].to_i    #сколько было потрачено в теге expenses
	loss_date = Date.parse(item.attributes["date"]) #парсим дату

	amount_by_day[loss_date] ||= 0
	# Если за день было несколько трат, результат мы должны просумирровать
	# Чтобы просумирровать мы должны инициализировать елемент хеша
	# amount_by_day[ключ дата] ||= если это значение пустое, то запиши 0, если нет - то оставь как есть
	amount_by_day[loss_date] += loss_sum
end

file.close

#на выходе у нас amount_by_day содержит хеш, где каждой дате сопоставлена сумма трат

sum_by_month = Hash.new # сумма трат за каждый месяц

current_month = amount_by_day.keys.sort[0].strftime("%B %Y")
# в цикле мы должны иметь указатель на текущий месяц
# устанавливаем ключ в самый первый месяц - сортируем хеш по ключах, берем 0-вой ключ и переделываем
# его в конструкцию "%B %Y" (июлт 2015)

amount_by_day.keys.sort.each do |key|
#берем все ключи, сортируем и по каждому делаем итерацию
	sum_by_month[key.strftime("%B %Y")] ||= 0
	# инициализируем в хеше sum_by_month ечейку, связанную с текущим месяцем, если она еще не была 
	# инициализирована = 0
	sum_by_month[key.strftime("%B %Y")] += amount_by_day[key]
	#добавляем в ячейу сумму затрат текущего дня, которую берем с массива amount_by_day
end

# ключ - месяц и год
# значение - сумма трат за этот месяц

#виведем заголовок для первого месяца
puts "-----[ #{current_month}, всего потрачено: #{sum_by_month[current_month]} грн. ]------"

amount_by_day.keys.sort.each do |key|
	if key.strftime("%B %Y") != current_month
		#если текущая дата не совпадает с выбраным месяцем
		current_month = key.strftime("%B %Y")
		puts "-----[ #{current_month}, всего потрачено: #{sum_by_month[current_month]} грн. ]------"
	end

	puts "\t#{key.day}: #{amount_by_day[key]} грн."
	#выводим информацию о трате за эту дату

end