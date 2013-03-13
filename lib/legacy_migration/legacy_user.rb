class LegacyUser < LegacyBase
      self.table_name = "users"

      # Method to migrate self
      def migrate_me!
	  # Get common data
	  name=self.login
	  # Crete new User
	  new_user=User.new(
	      :user_name => name,
	      :password => 'abcd1234',
	      :name => name,
	  )
	  # Set timestamps fields
	  new_user.created_at = self.created_on
	  new_user.updated_at = self.updated_on
	  # Validate
	  if not new_user.valid?
	      puts("error: #{self.class}->#{self.id}")
	      puts(new_user.errors.messages)
	      puts("Exiting")
	      exit
	  end
	  # Save record
	  new_user.save!
	  # Return id map
	  return [self.id, new_user.id]
      end

      # Method to test import
      def self.test_import
	  # Get first legacy record
	  @old_1=LegacyUser.first
	  # Get matching new
	  @new_1=User.where(:user_name => @old_1.login).first
	  # Test
	  self.raise_error('user_name') if @new_1.user_name != @old_1.login
	  self.raise_error('name') if @new_1.name != @old_1.login
	  self.raise_error('created_at') if @new_1.created_at != @old_1.created_on
	  self.raise_error('updated_at') if @new_1.updated_at != @old_1.updated_on
	  # Ok
	  puts("#{self.name} successfully imported")
	  return true
      end

      # Method to raise error
      def self.raise_error(field)
	  puts('-' * 10)
	  puts("Imported data does not match old data")
	  puts("Field: #{field}")
	  p @old_1
	  p @new_1
	  puts('-' * 10)
	  raise("Exiting, import failed")
      end
end
