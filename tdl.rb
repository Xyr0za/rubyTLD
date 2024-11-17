require "JSON"
require 'rainbow/refinement'
using Rainbow


class JsonReader
  def initialize(filename)
    @filename = filename
    @file = File.read(@filename) # Parse the file into a File object
    @hash = JSON.parse(@file) # Convert the file object in to a ruby hash
  end

  def hash
    @hash
  end
end

class ToDoList
  def initialize(path)
    @choice = ''
    @path = path
    @hash = JsonReader.new(@path).hash
    @entries = @hash.map { |key, value| Entry.new(key, value["ShortDesc"], value["LongDesc"], value["Completed"])}
  end

  def display_basic
    puts "+---+---+------------+----------------------+"
    puts "| " << 'i'.magenta << " | " << "?".yellow << " | " << "Task".cyan << "       | " << "Description".red << "          |"
    puts "+---+---+------------+----------------------+"
    @entries.each do |entry|
      out_string = "| #{@entries.find_index(entry) + 1}"
      out_string = out_string + ' | ' + (entry.completed ? "Y".green : "N".red) + ' | '
      out_string = out_string + entry.name.ljust(10, ' ') + ' | '
      out_string = out_string + entry.short_desc.ljust(20, ' ') + ' |'
      puts out_string
    end
    puts "+---+---+------------+----------------------+"
  end

  def display_detail(index)
    puts ""
    puts "{}".blue << " Task Description: ".white
    puts "---------------------".cyan
    puts @entries[index].long_desc << "\n"
    query = input("Edit? Y/N")
    if query.to_s[0].upcase == "Y"
      edit(index)
    end
  end

  def edit(index)
    query = input("Name, Tagline, Description, Status (N,T,D,S)").to_s
    query_selector = query[0].upcase
    if query_selector == "N"
      @entries[index].new_name(input("New name: "))
    elsif query_selector == "T"
      @entries[index].new_short_desc(input("New tagline: "))
    elsif query_selector == "D"
      @entries[index].new_long_desc(input("New description: "))
    elsif query_selector == "S"
      @entries[index].new_status(!@entries[index].completed)
    end
  end

  def await_choice
    puts "{}".blue << " Select a task:  "
    @choice = await
  end

  def enact
    if Range.new(0, @entries.length).map{|a| a.to_s}.include?(@choice.to_s)
      if @choice != '0'
        display_detail(@choice.to_i - 1)
      else
        name = input("Name: ")
        tagline = input("Tagline: ")
        description = input("Description: ")
        add_item(Entry.new(name, tagline, description, false))
      end
    end

    if @choice[0] == "r" || @choice[0] == "R"
      query = input("Index to pop: ")
      @hash.delete(@entries[query.to_i - 1].name)
      @entries.delete_at(query.to_i - 1)
    end
  end

  def save
    @entries.each do |element|
      # noinspection RubyModifiedFrozenObject
      @hash[element.name] = {
        "ShortDesc" => element.short_desc,
        "LongDesc" => element.long_desc,
        "Completed" => element.completed,
      }
    end
    File.write("toDoList.json", @hash.to_json)
  end

  def add_item(new_entry)
    @entries += [new_entry]
  end

  def hash
    @hash
  end

  def entries
    @entries
  end

end

#

class Entry
  def initialize(name, short_desc, long_desc, completed)
    @name = name
    @short_desc = short_desc
    @long_desc = long_desc
    @completed = completed
  end

  def name
    @name
  end

  def short_desc
    @short_desc
  end

  def long_desc
    @long_desc
  end

  def completed
    @completed
  end

  def new_name(new)
    @name = new
    puts @name
  end

  def new_short_desc(new)
    @short_desc = new
  end

  def new_long_desc(new)
    @long_desc = new
  end

  def new_status(new)
    @completed = new
  end

end


##

def await
  gets.chomp
end

def input(txt)
  puts "{} ".blue << txt
  gets.chomp
end

##

const_path = "toDoList.json"

puts "+--------------+".cyan
puts "| ".cyan << 'Sapphire TDL'.white << " |".cyan
puts "+--------------+".cyan


while true # Main loop
  list = ToDoList.new(const_path) # Parse data from JSON file
  list.display_basic # Display the TODO List
  list.await_choice # Awaits user input
  list.enact # Causes user based changes
  list.save # Writes data to json file
end
