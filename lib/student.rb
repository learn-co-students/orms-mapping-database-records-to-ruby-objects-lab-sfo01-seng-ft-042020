class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    stud = Student.new
    stud.id, stud.name, stud.grade = row
    stud
  end

  def self.all
    find_between_grades(0, 12)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL
    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.all_students_in_grade_9
    find_between_grades(9, 9)
  end

  def self.students_below_12th_grade
    find_between_grades(0, 11)
  end

  def self.first_X_students_in_grade_10(x)
    find_between_grades(10, 10, x)
  end

  def self.first_student_in_grade_10
    find_between_grades(10, 10, 1).first
  end

  def self.all_students_in_grade_X(x)
    find_between_grades(x, x)
  end
  
  def self.find_between_grades(low, high, limit = nil) 
    params = [low, high, limit].compact
    if limit.nil?
      sql = <<-SQL
      SELECT * FROM students WHERE grade BETWEEN ? AND ? 
      SQL
    else
      sql = <<-SQL
      SELECT * FROM students WHERE grade BETWEEN ? AND ? LIMIT ? 
      SQL
    end
    DB[:conn].execute(sql, params).map {|row| new_from_db(row)}
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
