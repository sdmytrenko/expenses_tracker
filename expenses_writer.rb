
require "rexml/document" # подключаем парсер
require "date" # будем использовать операции с данными

puts "На что вы потратили деньги?"
expense_text = STDIN.gets.chomp

puts "Сколько потратили?"
expense_amount = STDIN.gets.chomp.to_i

puts "Укажите дату траты в формате ДД.ММ.ГГГГ, (12.08.2016) (пустое поле - сегодня)"
date_input = STDIN.gets.chomp

expense_date = nil

if date_input == ''
	expense_date = Date.today
else
	expense_date = Date.parse(date_input)
	#Date.parse(дата_в_строке) - преобразовать строку в обьект даты
end

puts "В какую категорию занести трату?"
expense_category = STDIN.gets.chomp


current_path = File.dirname(__FILE__)
file_name = current_path + "/my_expenses.xml"

file = File.new(file_name, "r:UTF-8")

begin
	doc = REXML::Document.new(file)
rescue REXML::ParseException => e
	puts "XML файл похоже битый"
	abort e.message
end

file.close

expenses = doc.elements.find('expenses').first
#find возвращает колекцию найденых тегов, first - выбираем первый
expense = expenses.add_element 'expense' , {
						'amount' => expense_amount,
						'category' => expense_category,
						'date' => expense_date.to_s
							}
# xml_element.add_element(имя, атрибуты) - добавить дочерний елемент (тег)

expense.text = expense_text #вызвать содержимое тега

file = File.new(file_name, "w:UTF-8")
doc.write(file, 2) #2 - количество отсупов в xml-файле
file.close

puts "Запись успешно сохранена"