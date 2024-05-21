require 'monitor'

class Communication
  include MonitorMixin # Включаем модуль MonitorMixin для использования мониторов

  def initialize
    super() # Инициализация MonitorMixin
    @connected = false # Переменная, указывающая, установлено ли соединение
    @condition = new_cond # Условная переменная для управления ожиданием потоков
  end

  def call(person, id = nil)
    synchronize do # Начало критической секции
      identifier = id ? "#{person} ##{id}" : person # Формируем идентификатор потока с номером (если есть)
      puts "#{identifier} пытается зайти в критическую секцию"

      while @connected # Если соединение установлено, поток ждет
        @condition.wait
      end

      @connected = true
      puts "#{identifier} зашел в критическую секцию и установил соединение"
      sleep(rand(1..3)) # Имитируем время разговора
      puts "#{identifier} вышел из критической секции"
      @connected = false # Освобождаем соединение
      @condition.signal # Сигнализируем другим потокам, что соединение освободилось
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
