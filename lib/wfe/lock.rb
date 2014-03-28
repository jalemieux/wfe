require 'active_record' unless defined?(ActiveRecord)


# Active Record Semaphore
#
# Author::    jacques@marketo.com
# Copyright:: Copyright (c) marketo inc.
#
# ==== Description
# Centralized mutex used for synchronization mechanism between processes
# running on various servers.
#
# ==== Usage Example
#
#   obj = ActiveRecord::Base.establish_connection(
#     :adapter  => "mysql2",
#     :host     => "127.0.0.1",
#     :username => "root",
#     :password => "unlock",
#     :database => "test"
#   )
#
#   lock_name = 's1'
#   raise Exception.new("cannot acquire lock") unless Wfe::Lock.open?(lock_name, 60*24*60)
#   # do some work....
#   puts 'unlocked!' if Wfe::Lock.release(lock_name)
#
#
class Wfe::Lock < ActiveRecord::Base
  self.table_name = 'semaphore'
  validates_presence_of :name, :message => "can't be blank"

  # Requests a lock on semaphore 'name'
  #
  # Returns true on success, false on failure.
  def self.acquire?(name, lock_duration = 500)
    semaphore_open = false
    now = Time.now
    begin
      # if the semaphore's missing the db (never used before) create it with an expired lock timeout
      Wfe::Lock.create(:name => name, :locked_until => now - lock_duration) if !Wfe::Lock.exists?({ :name => name })
      Wfe::Lock.transaction do
        semaphore = Wfe::Lock.find_by_name(name, :lock => "LOCK IN SHARE MODE")
        if semaphore and semaphore.locked_until <= now
          semaphore.locked_until = now + lock_duration
          semaphore_open = true if semaphore.save
        end
      end
      return semaphore_open
    rescue ActiveRecord::StatementInvalid => e
      # deadlock
      return false
    end
  end

  # Release lock on semaphore 'name'
  # Returns true on success, false on failure.
  def self.release(name)
    semaphore_close = false
    return true if !Wfe::Lock.exists?({ :name => name })
    begin
      Wfe::Lock.transaction do
        semaphore = Wfe::Lock.find_by_name(name, :lock => "LOCK IN SHARE MODE")
        semaphore_close = true if semaphore.delete
      end
      return semaphore_close
    rescue ActiveRecord::StatementInvalid => e
      return false
    end
  end
end

