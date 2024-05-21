require 'thread'

class Communication
  def initialize
    @mutex = Mutex.new # Мьютекс для управления доступом к критической секции
    @semaphore = Mutex.new # Семафор для контроля очередности потоков
    @connected = false  # Переменная, указывающая, установлено ли соединение
  end

  def call(person, id = nil)
    @semaphore.synchronize do # Начало критической секции для очередности потоков
      identifier = id ? "#{person} ##{id}" : person # Формируем идентификатор потока с номером (если есть)
      puts "#{identifier} пытается зайти в критическую секцию"
      @mutex.synchronize do # Начало критической секции для проверки и установки соединения
        if @connected
          puts "#{identifier} вышел из критической секции, так как соединение уже установлено"
        else
          @connected = true
          puts "#{identifier} зашел в критическую секцию и установил соединение"
          sleep(rand(1..3)) # Имитируем время разговора
          puts "#{identifier} вышел из критической секции"
          @connected = false # Освобождаем соединение
        end
      end
    end
  end
end

communication = Communication.new

threads = []

# Создаем потоки для каждого участника
threads << Thread.new { communication.call("Полуэкт") }
2.times { |i| threads << Thread.new { communication.call("Бабушка", i + 1) } }
threads << Thread.new { communication.call("Мама") }
3.times { |i| threads << Thread.new { communication.call("Девушка", i + 1) } }

# Дожидаемся завершения всех потоков
threads.each(&:join)