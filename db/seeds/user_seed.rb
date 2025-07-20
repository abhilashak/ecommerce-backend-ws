# User seed data
class UserSeed
  def self.create_users(count)
    puts "Creating #{count} sample users..."
    
    # Sample user data
    first_names = [
      "John", "Jane", "Michael", "Sarah", "David", "Emily", "Robert", "Lisa", 
      "William", "Jennifer", "James", "Mary", "Christopher", "Patricia", "Daniel", 
      "Linda", "Matthew", "Elizabeth", "Anthony", "Barbara", "Mark", "Susan", 
      "Donald", "Jessica", "Steven", "Karen", "Paul", "Nancy", "Andrew", "Betty",
      "Joshua", "Helen", "Kenneth", "Sandra", "Kevin", "Donna", "Brian", "Carol",
      "George", "Ruth", "Edward", "Sharon", "Ronald", "Michelle", "Timothy", "Laura",
      "Jason", "Sarah", "Jeffrey", "Kimberly", "Ryan", "Deborah", "Jacob", "Dorothy"
    ]
    
    last_names = [
      "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
      "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
      "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
      "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
      "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill",
      "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell",
      "Mitchell", "Carter", "Roberts", "Gomez", "Phillips", "Evans", "Turner"
    ]
    
    domains = ["gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com", "aol.com"]
    
    count.times do |i|
      first_name = first_names.sample
      last_name = last_names.sample
      email = "#{first_name.downcase}.#{last_name.downcase}#{rand(100..999)}@#{domains.sample}"
      
      User.create!(
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: "password123",
        password_confirmation: "password123"
      )
      
      print "."
    end
    
    puts "\n✅ Successfully created #{User.count} users!"
    puts "📧 Sample users:"
    User.limit(5).each do |user|
      puts "   #{user.full_name} - #{user.email}"
    end
  end
end
