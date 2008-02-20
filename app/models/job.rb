# myExperiment: app/models/job.rb
#
# Copyright (c) 2008 University of Manchester and the University of Southampton.
# See license.txt for details.

class Job < ActiveRecord::Base
  
  belongs_to :runnable, :polymorphic => true
  validates_presence_of :runnable
  validates_presence_of :runnable_version
  
  belongs_to :runner, :polymorphic => true
  validates_presence_of :runner
  
  belongs_to :experiment
  validates_presence_of :experiment
  
  belongs_to :user
  validates_presence_of :user
  
  format_attribute :description
  
  validates_presence_of :title
  
  serialize :inputs_data, Hash
  
  def authorized?(action_name, c_utor=nil)
    # Use authorization logic from parent Experiment
    return self.experiment.authorized?(action_name, c_utor)
  end
  
  def run_errors
    @run_errors ||= [ ]
  end
  
  def allow_run?
    self.job_uri.blank? and self.submitted_at.blank?
  end
  
  def submit_and_run
    run_errors.clear
    success = true
    
    if allow_run?
      
      begin
        
        # Only continue if runner service is valid
        unless runner.service_valid?
          run_errors.add("The #{humanize self.runner_type} is invalid or inaccessible. Please check the settings you have registered for this Runner.")
          success = false
        end
        
        # Ask the runner for the uri for the runnable object on the service
        # (should submit the object to the service if required)
        remote_runnable_uri = runner.get_remote_runnable_uri(self.runnable_type, self.runnable_id, self.runnable_version)
        
        if remote_runnable_uri
          # Submit inputs (if available) to runner service
          unless self.inputs_data.blank?
            self.inputs_uri = runner.submit_inputs(self.inputs_data)
            self.save!
          end
          
          # Submit the job to the runner, which should begin to execute it, then get status
          self.job_uri = runner.submit_job(remote_runnable_uri, self.inputs_uri)
          self.submitted_at = Time.now
          self.last_status = runner.get_job_status(self.job_uri)
          self.last_status_at = Time.now
          self.save!
        else
          run_errors.add("Failed to submit the runnable item to the runner service. The item might not exist anymore or access may have been denied at the service.")
          success = false
        end
        
      rescue Exception => ex
        run_errors.add("An exception has occurred whilst submitting and running this job: #{ex}")
        success = false
      end
      
    else
      run_errors.add("This Job has already been submitted and cannot be rerun.")
      success = false;
    end
    
    return success
    
  end
  
  def last_status
    begin
      if self.job_uri
        self.last_status = runner.get_job_status(self.job_uri)
        self.last_status_at = Time.now
        self.save
      end 
    rescue Exception => ex
      puts "ERROR occurred whilst fetching last status for job #{self.job_uri}. Exception: #{ex}"
    end
    
    return self[:last_status]
  end
  
  def inputs_data=(data)
    if allow_run?
      self[:inputs_data] = data
    end
  end
  
protected
  
end
