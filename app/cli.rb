require 'pry'
require 'TTY'

class CLI

  def initialize
   @prompt = TTY::Prompt.new
   @pastel = Pastel.new
   @font = TTY::Font.new(:doom)
 end

 def welcome
   puts @pastel.blue(@font.write("Flatiron - WOD",letter_spacing: 2))
   2.times {line_break}
   puts @pastel.green.bold'                             ᕦ╏ ʘ̆ ‸ ʘ̆ ╏ᕤ'
   line_break
   puts @pastel.red.bold"                            ASPIRING CODER"
   line_break
   puts @pastel.red.bold'          Need to focus on your code craft, but still want to keep working out?'
   puts @pastel.red'               Flatiron Workout of the Day app will:'
   puts @pastel.red'               * suggest a routine that suits your busy schedule'
   puts @pastel.red'               * discover exciting exercises you never knew existed'
   puts @pastel.red'               * sharpen your mind for coding whilst you workout'
   line_break
   puts @pastel.red.bold'                       ARE YOU READY TO GET MOVING?'
   line_break
   puts @pastel.green.bold'                            ᕙ( * •̀ ᗜ •́ * )ᕗ'
   2.times {line_break}
 end

 def logo
   puts @pastel.blue(@font.write("Flatiron - WOD",letter_spacing: 2))
   puts @pastel.blue"٩◔‿◔۶ Logged in as: #{@user.name}"
   2.times {line_break}
 end

 def reset #clears screen
   system("clear")
 end

 def line_break #for formatting
   puts ""
 end

  def start
    reset
    welcome
    get_name
    set_up_user_and_greet
    main_menu
  end

  def get_name
    @name = @prompt.ask("What is your name? (Profanity not advised, you might regret it.)") do |q|
        q.required true
    end
    @name = @name.split.map(&:capitalize).join(" ")
  end

  def set_up_user_and_greet
    if User.find_by(name: @name)
      @user = User.find_by(name: @name)
      @duration = @user.exercises.sum(:duration)
      puts @pastel.blue"Welcome back #{@name}. Have a great workout today!"
      `say -v Samantha "Welcome back #{@name}. Have a great workout today!"`
      spinner = TTY::Spinner.new("[:spinner] Loading app...", format: :pulse_2)
      spinner.auto_spin
      sleep(1)
      spinner.stop("Let's go!")
    else
      @user = User.create(name: @name, duration: 0)
      @duration = @user.exercises.sum(:duration)
      puts @pastel.blue"Hey, #{@name}, it's your first time here, welcome! Hope you enjoy our app!"
      `say -v Samantha "Hey, #{@name}, it's your first time here, welcome! Hope you enjoy our app!"`
      spinner = TTY::Spinner.new("[:spinner] Loading app...", format: :pulse_2)
      spinner.auto_spin
      sleep(1)
      spinner.stop("Let's go!")
    end
  end

  def main_menu
    reset
    logo
    puts @pastel.blue.bold"Current Page: Main Menu"
    answer = @prompt.select("What would you like to do today?", per_page: 7) do |menu|
      menu.enum '.'
      menu.choice "Workout NOW    ᕙ( * •̀ ᗜ •́ * )ᕗ",1
      menu.choice "Customise workout",2
      menu.choice "Exercises library",3
      menu.choice "Find a nearby gym",4
      menu.choice "Delete my things",5
      menu.choice "Change user",6
      menu.choice "Exit",7
    end

    case answer
      when 1
        new_wod
      when 2
        your_workout_menu
      when 3
        exercises_menu
      when 4
        find_gym
        back_to_main_menu
      when 5
        delete_things_menu
      when 6
        change_user
      when 7
        exit
    end
  end

  def back_to_main_menu
    answer = @prompt.select("Back to Main Menu.") do |menu|
      menu.choice "Hit Enter now.", 1
    end
    answer.to_i == 1 ? main_menu : ""
  end

  def your_workout_menu
    reset
    logo
    puts @pastel.blue.bold"Current Page: --Workout of the Day Menu"
    answer = @prompt.select("Here are some things you could do now:") do |menu|
      menu.enum '.'
      menu.choice "Review your last WOD", 1
      menu.choice "Get a new WOD", 2
      menu.choice "Create your own WOD", 3
      menu.choice "Back to Main Menu", 4
    end

    case answer.to_i
      when 1
        last_wod
      when 2
        new_wod
      when 3
        create_wod
      when 4
        main_menu
    end
  end

  def back_to_your_workout_menu
    answer = @prompt.select("Go back to previous menu.") do |menu|
      menu.choice "Hit Enter now.", 1
    end
    answer == 1 ? your_workout_menu : ""
  end

  def last_wod
    if @duration == 0
      puts @pastel.red("Looks like you don't have a previous WOD yet.")
      back_to_your_workout_menu
    else
      reset
      view_wod
      do_you_like_this_wod
    end
  end

  def my_wod
    @user.exercises
  end

  def view_wod
   logo
   puts "Reviewing Your WOD (#{@duration} mins)".center(200)
   duration_notes
   line_break
   puts "==============================================================".center(200)
   my_wod.each_with_index do |o,i|
     line_break
     puts "#{i+1}. #{o.name} (#{o.duration} mins)".center(200)
     puts "#{o.description}".center(200)
     line_break
     puts "==============================================================".center(200)
   end
 end

 def duration_notes
   if @duration < 5
     puts @pastel.red("         Your WOD.duration < 5 minutes.").center(200)
     puts @pastel.red("         Less than five minutes? You're not even trying").center(200)
   elsif @duration == 5
     puts @pastel.green("      Five minutes? You call that a workout?").center(200)
   elsif @duration > 5 && @duration <= 10
     puts @pastel.green("      Not bad, finish this and you will have burned 5 biscuits and written 50 lines of code ").center(200)
   elsif @duration > 10 && @duration <= 15
     puts @pastel.green("      Not bad, finish this and you will have burned 10 biscuits and written 100 lines of code ").center(200)
   elsif @duration > 15 && @duration <= 25
     puts @pastel.green("      You're ambitious, finish this and you will have burned 15 biscuits and written 200 lines of code  ").center(200)
   elsif @duration > 25 && @duration <= 30
     puts @pastel.green("      Your're a dedicated rubygymnist, finish this and you will have burned 20 biscuits and written 300 lines of code ").center(200)
   elsif @duration > 30
     puts @pastel.red("      Your current WOD.duration > 30 minutes.").center(200)
     puts @pastel.red("           You must enjoy pain").center(200)
   end
 end

 def new_wod
    if @duration == 0
      reset_duration
      get_random_wod
    else
      @prompt.say("Your last WOD was #{@duration} mins.", color: :green)
      answer = @prompt.select("Would you like to change your workout duration today?") do |menu|
        menu.choice "Yes", 1
        menu.choice "No", 2
      end
      case answer
      when 1
        destroy_my_routine
        reset_duration
        get_random_wod
      when 2
        get_random_wod
      end
    end
  end

  def reset_duration
    @duration = @prompt.ask("How long would you like to workout today, in minutes? (MINIMUM 5 MINS, DON'T BE LAZY! MAXIMUM 30 MINUTES, DON'T BE A HERO.)") do |q|
      q.in '5-30'
      q.messages[:range?] = 'Which part of between 5 and 30 did you not understand???'
    end
    @duration = @duration.to_i
  end

  def get_random_wod
    current_duration = 0
    until current_duration >= @duration
      selected = Exercise.all.sample
      if (current_duration += selected.duration) <= @duration
        Routine.create(user_id: @user.id, exercise_id: selected.id)
      else
        current_duration -= selected.duration
      end
    end
    reset
    view_wod
    do_you_like_this_wod
  end

  def do_you_like_this_wod
    answer = @prompt.select("What do you think?") do |menu|
      menu.enum '.'
      menu.choice "Great WOD! Let's workout now!", 1
      menu.choice "Don't like it. Get a new WOD for me please.", 2
      menu.choice "Don't like it. I'll create my own WOD.", 3
      menu.choice "Not feeling it now. Take me back to the previous menu.", 4
    end

    case answer
      when 1
        confirm_wod_and_go
      when 2
        destroy_my_routine
        reset_duration
        get_random_wod
      when 3
        create_wod
      when 4
        your_workout_menu
      end
  end

  def confirm_wod_and_go
    answer = @prompt.select("Are you ready for this?") do |menu|
      menu.choice "Yes, let's do this!", 1
      menu.choice "Not really.", 2
    end
    case answer
    when 1
      run_wod
    when 2
      @prompt.say("Fine, come back when you're ready!", color: :green)
      back_to_your_workout_menu
    end
  end

  def destroy_my_routine
    Routine.where(user_id: @user.id).destroy_all
  end

  def create_wod
    destroy_my_routine

    hash = Hash.new
    Exercise.all.each do |o|
      key = "#{o.id}. #{o.name} (#{o.duration} mins) - #{o.description}"
      hash[key] = o.id
    end
    puts @pastel.green.bold("You are now responsible for your own workout duration!")
    puts @pastel.green.bold("Choose at least one")
    selected = @prompt.multi_select("Pick your exercises to be saved in your WOD (>'o')>", hash, required: true, per_page: 30)
     if selected.empty?
     puts @pastel.red.bold("Make up your mind, choose AT LEAST ONE")
     create_wod
      else
      @my_wod = selected.each {|i| Routine.create(user_id: @user.id, exercise_id: i)}
      @duration = @user.exercises.sum(:duration).to_i
      reset
      view_wod
      do_you_like_this_wod
  end
end

  # def create_wod
  #   destroy_my_routine
  #
  #   hash = Hash.new
  #   Exercise.all.each do |o|
  #     key = "#{o.id}. #{o.name} (#{o.duration} mins) - #{o.description}"
  #     hash[key] = o.id
  #   end
  #   puts @pastel.green.bold("You are now responsible for your own workout duration!")
  #   selected = @prompt.multi_select("Pick your exercises to be saved in your WOD (>'o')>", hash)
  #   @my_wod = selected.each {|i| Routine.create(user_id: @user.id, exercise_id: i)}
  #   @duration = @user.exercises.sum(:duration).to_i
  #   reset
  #   view_wod
  #   do_you_like_this_wod
  # end

  def exercises_menu
    reset
    logo
    puts @pastel.blue.bold"Current Page: --Exercises Library Menu"
    answer = @prompt.select("Here are some things you could do now:") do |menu|
      menu.enum '.'
      menu.choice "View the entire exercise library", 1
      menu.choice "View all your custom exercises", 2
      menu.choice "Edit/Delete your custom exercise", 3
      menu.choice "Create a new custom exercise", 4
      menu.choice "Back to Main Menu", 5
    end

    case answer.to_i
      when 1
        view_all_exercises
      when 2
        if my_custom_exercises.length == 0
          @prompt.say("You haven't created any custom exercises yet. Perhaps you would like to create one now? ≧◡≦", color: :red)
          back_to_exercises_menu
        else
          view_my_custom_exercises
        end
      when 3
        if my_custom_exercises.length == 0
          @prompt.say("You have no custom exercises to edit or delete. Please select another option.（ミ￣ー￣ミ)", color: :red)
          back_to_exercises_menu
        else
          select_my_custom_exercise
          edit_or_delete_custom_exercise
        end
      when 4
        create_custom_exercise
      when 5
        main_menu
    end
  end

  def back_to_exercises_menu
    answer = @prompt.select("Go back to previous menu.") do |menu|
      menu.choice "Hit Enter now.", 1
    end
    answer == 1 ? exercises_menu : ""
  end

  def view_all_exercises
    reset
    logo
    puts "Reviewing Exercises Library".center(200)
    line_break
    puts "==============================================================".center(200)
    Exercise.all.each_with_index do |o,i|
      line_break
      puts "#{i+1}. #{o.name} (#{o.duration} mins)".center(200)
      puts "#{o.description}".center(200)
      line_break
      puts "==============================================================".center(200)
    end
    back_to_exercises_menu
  end

  def create_custom_exercise
    @prompt.say("(°∀°) Have a signature move? Share it with other users!")
    e_name = @prompt.ask("What is your exercise name called?") do |q|
      q.required true
    end
    e_name = e_name.split.map(&:capitalize).join(" ")

    e_description = @prompt.ask("Please enter a short description of #{e_name}:") do |q|
      q.required true
    end

    e_duration = @prompt.ask("How many minutes will it take to complete this exercise?") do |q|
      q.required true
      q.in '1-30'
      q.messages[:range?] = "Coders ain't got any time, keep it within 30 mins!"
    end
    Exercise.create(name: e_name, description: e_description, duration: e_duration, user_id: @user.id)
    @prompt.say("ヽ(^◇^*)/ #{e_name} is now on our exercise library!", color: :green)
    back_to_exercises_menu
  end

  def my_custom_exercises
    @my_exercises = Exercise.where(user_id: @user.id)
  end

  def view_my_custom_exercises
    reset
    logo
    puts "Reviewing All Your Custom Exercises".center(200)
    line_break
    puts "==============================================================".center(200)
    @my_exercises.each_with_index do |o,i|
      line_break
      puts "#{i+1}. #{o.name} (#{o.duration} mins)".center(200)
      puts "#{o.description}".center(200)
      line_break
      puts "==============================================================".center(200)
    end
    back_to_exercises_menu
  end

  def select_my_custom_exercise
    hash = Hash.new
    my_custom_exercises.all.each do |o|
      key = "#{o.id}. #{o.name} (#{o.duration} mins) - #{o.description}"
      hash[key] = o.id
    end

    @selected_custom_exercise_id = @prompt.select("Please select the custom exercise you want to edit/delete.", hash) #the exercise id
    @selected_custom_exercise = Exercise.find(@selected_custom_exercise_id)
  end

  def edit_or_delete_custom_exercise
    answer = @prompt.select("Would you like to edit or delete #{@selected_custom_exercise.name}?") do |menu|
      menu.choice "Edit", 1
      menu.choice "Delete", 2
      menu.choice "Go back. I change my mind!", 3
    end

    case answer
      when 1
        edit_my_custom_exercise
        back_to_exercises_menu
      when 2
        delete_my_custom_exercise
        back_to_exercises_menu
      when 3
        back_to_exercises_menu
    end
  end

  def edit_my_custom_exercise
    name = @prompt.ask("Please enter the updated name: (Currently: #{@selected_custom_exercise.name}. Hit Enter if you don't want to change it.)")
    if name.to_s.length == 0
      name = @selected_custom_exercise.name
      name = name.split.map(&:capitalize).join(" ")
    else
      name = name.split.map(&:capitalize).join(" ")
    end

    description = @prompt.ask("Please enter the updated description: (Currently: #{@selected_custom_exercise.description}. Hit Enter if you don't want to change it.)")
    if description.to_s.length == 0
      description = @selected_custom_exercise.description
    end

    duration = @prompt.ask("Please enter the updated duration: (Currently: #{@selected_custom_exercise.duration} minutes.)") do |q|
      q.required true
      q.in '1-30'
      q.messages[:range?] = "Coders ain't got any time, keep it within 30 mins!"
    end
    @selected_custom_exercise.duration = duration

    Exercise.update(@selected_custom_exercise_id, name: name, description: description, duration: duration)
    @prompt.say("ヽ(^◇^*)/ All updated in our exercises library as below:", color: :green)
    @prompt.say("Custom Exercise Name: #{@selected_custom_exercise.name}")
    @prompt.say("Description: #{@selected_custom_exercise.description}")
    @prompt.say("Duration: #{@selected_custom_exercise.duration} mins")
  end

  def delete_my_custom_exercise
    @selected_custom_exercise.destroy
    @prompt.say("The exercise has been deleted from the library ┐(‘～`；)┌\n")
  end

  def delete_things_menu
    reset
    logo
    puts @pastel.blue.bold"Current Page: --Delete My Things Menu"
    @prompt.say("Oh no, what did we do? Did you get here by mistake? ☉▵☉")
    answer = @prompt.select("What exactly are you looking for?") do |menu|
      menu.enum '.'
      menu.choice "Delete all my custom exercises.", 1
      menu.choice "Delete my account, including all custom exercises I have created.", 2
      menu.choice "Forget about it, take me back to Main Menu.", 3
    end

    case answer
    when 1
      delete_all_my_custom_exercises
      back_to_main_menu
    when 2
      delete_account
      exit
    when 3
      @prompt.say("(¬‿¬) Glad you chose to not be a destroyer!")
      back_to_main_menu
    end
  end

  def delete_all_my_custom_exercises
    answer = @prompt.select("Are you very, very, very, very sure?") do |menu|
      menu.choice "Yep!", 1
      menu.choice "Er.", 2
    end

    case answer
    when 1
      Exercise.where(user_id: @user.id).destroy_all
      @prompt.say("ヾ｜￣ー￣｜ﾉ All your custom exercises are now deleted.")
    when 2
      reset
      main_menu
    end
  end

  def delete_account
    answer = @prompt.select("Are you very, very, very, very sure?") do |menu|
      menu.choice "Yep!", 1
      menu.choice "Er.", 2
    end
    case answer
    when 1
      delete_all_my_custom_exercises
      Routine.where(user_id: @user.id).destroy_all
      User.where(id: @user.id).destroy_all
      @prompt.say("(╥_╥) Sad to see you go but hope you have a good life.")
    when 2
      reset
      main_menu
    end
  end

  def exit
    reset
  end

  def change_user
    start
  end

  def find_gym
    @postcode = @prompt.ask("What is your postcode?")
    Launchy.open("www.google.com/maps/search/?api=1&query=gyms+near #{@postcode}")
  end

  def run_wod
   if @duration == 0
     puts @pastel.red("You have no exercises in your WOD. Please go back and select some exercises.")
     back_to_your_workout_menu
   else
     reset
     run_wod_welcome
     run_wod_loop_with_breaks
     run_wod_ending
     back_to_main_menu
   end
 end

  def run_wod_welcome
    print "\033[2J" #print static_workout animation
    File.foreach(File.expand_path("../../lib/animations/static_workout/1.rb", __FILE__)){ |f| puts f }
    `say -v Amelie "Are you ready #{@user.name}?"`
   sleep(1)
  end

  def run_wod_loop_with_breaks
    my_wod.each_with_index do |o,i|
      reset
      20.times {line_break}
      puts "#{i+1}. #{o.name} (#{o.duration} mins)".center(200)
      puts "#{o.description}".center(200)
      `say -v Samantha "Exercise #{i+1}. #{o.name} for #{o.duration} minutes, where you #{o.description}"`
      voice_countdown
      play_whistle
      sleep(2)
      play_workout_music
      workout_animation
      sleep(2)
      play_whistle
      reset
      sleep(2)
      meditation
      play_whistle
      reset
      sleep(2)
      stop_it
      break if @stop_answer.length > 0
    end
  end

  def stop_it
    @stop_answer = @prompt.keypress("Want to give up now? Press any key in the next :countdown seconds...!", timeout: 3)
    @stop_answer = @stop_answer.to_s
  end

  def voice_countdown
    `say -v Samantha "Starting in 3"`
    `say -v Samantha "2"`
    `say -v Samantha "1"`
  end

  def play_whistle
    pid = fork{ exec 'afplay', File.expand_path("../../lib/media/goat_scream.mp3", __FILE__) }
  end

  def workout_animation
     i = 1
     while i < 40 #this runs through the entire animation once, don't touch.
       print "\033[2J"
       File.foreach(File.expand_path("../../lib/animations/workout/#{i}.rb", __FILE__)){ |f| puts f }
       sleep(0.1)
       i += 1
     end
  end

  def play_workout_music
   pid = fork{ exec 'afplay', File.expand_path("../../lib/media/workout_music.mp3", __FILE__) }
 end

  def meditation
    `say -v Samantha "Break time. Meditate with Julia for 30 seconds."`
    play_meditation_music
    2.times do
      i = 1
      while i < 20 #this runs through the entire animation once, don't touch.
        print "\033[2J"
        File.foreach(File.expand_path("../../lib/animations/meditation/#{i}.rb", __FILE__)){ |f| puts f }
        sleep(0.2)
        i += 1
      end
    end
  end

  def play_meditation_music
    pid = fork{ exec 'afplay', File.expand_path("../../lib/media/meditation_clean.mp3", __FILE__) }
  end

  def run_wod_ending
    if @stop_answer.length > 0
      `say -v Samantha "Pry harder next time, but all done for now!"`
    elsif @stop_answer.length == 0
      `say -v Samantha "All done champion. You made it to the end!"`
    end
  end

end
