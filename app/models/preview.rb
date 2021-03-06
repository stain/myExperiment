# myExperiment: app/models/preview.rb
#
# Copyright (c) 2011 University of Manchester and the University of Southampton.
# See license.txt for details.

class Preview < ActiveRecord::Base

  PREFIX = "tmp/previews"

  after_save :clear_cache

  belongs_to :image_blob, :class_name  => "ContentBlob",
                          :foreign_key => :image_blob_id,
                          :dependent   => :destroy,
                          :autosave    => true

  belongs_to :svg_blob,   :class_name  => "ContentBlob",
                          :foreign_key => :svg_blob_id,
                          :dependent   => :destroy,
                          :autosave    => true

  def file_name(type)
    "#{PREFIX}/#{id}/#{type}"
  end

  def clear_cache
    FileUtils.rm_rf("#{PREFIX}/#{id}")
  end
end

