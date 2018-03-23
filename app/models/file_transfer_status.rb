class FileTransferStatus

  def self.get_datetime_FTS_value date
    date.strftime("%m-%d-%Y %H:%M")
  end

  def self.get_yyyy_mm_dd_h_m_s_format date
    date.strftime("%Y-%m-%d %H:%M:%S")
  end
end