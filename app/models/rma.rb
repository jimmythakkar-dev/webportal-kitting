class Rma

  REASON_CODES = {
    "" => "Select Reason Code",
    :R01 => "Quality Issue; form/fit/function",
    :R02 => "Wrong Part",
    :R03 => "Duplicate Shipment",
    :R04 => "Short/Overship",
    :R05 => "Did not order",
    :R06 => "Order Cancelled",
    :R07 => "Early Delivery",
    :R08 => "Paperwork/Documentation Issue"
  }

  def self.data_hash_for_creating_rma(params,user_id)
    part_nos = JSON.parse(params["part_nos"])

    ####### Saving Images ############
    images_key = params.select{ |k,v| k.start_with? "image" }.collect {|key,val| key}

    attachmentpath = []
    unless images_key.blank?
      path = Rma.image_path
      FileUtils.mkdir_p path

      images_key.each do |img_key|
        File.open(path + "/" + params[img_key].original_filename, 'wb') do |file|
          file.write(params[img_key].read)
        end
        attachmentpath << path + "/" + params[img_key].original_filename
      end
    end

    ########## Creating RMA Hash #########
    qty = []
    serial_no = []
    counter = 1
    params.select{ |k,v| k.start_with? "qty" }.collect {|key,val|
      qty << val
      serial_no << counter
      counter = counter + 1
    }
    img_labels = params.select{ |k,v| k.start_with? "label" }.collect {|key,val| val }
    data_hash = {"userId" => user_id, "hostName" => APP_CONFIG['rma_host_name'], "contactName" => params[:name], "contactEmail" => params[:email], "pnSerialNo" => serial_no,
      "contactFax" => params[:fax], "returnReason" => params[:reason], "reasonCode" => params[:reason_code], "returnPns" => part_nos, "attachmentDesc" => img_labels,
      "attachmentPath" => attachmentpath, "invoiceNo" => params[:invoice_num], "invYear" => params[:year], "returnQty" => qty, "replPnReq" => params[:replace_part].to_s}

    data_hash
  end

  def self.save_images(params)
    ####### Saving Images ############
    images_key = params.select{ |k,v| k.start_with? "image" }.collect {|key,val| key}

    attachmentpath = []
    ids = []
    unless images_key.blank?
      path = APP_CONFIG['temp_image_path']
      FileUtils.mkdir_p path

      images_key.each do |img_key|
        File.open(path + "/" + params[img_key].original_filename, 'wb') do |file|
          file.write(params[img_key].read)
        end
        ids << img_key.gsub("image","")
        #extension = params[img_key].original_filename.split(".")[1]
        #attachmentpath << "data:image/"+ extension +";base64," + Base64.encode64(File.read(path + "/" + params[img_key].original_filename)).gsub("\n", '')
        attachmentpath << path.gsub("public","") + "/" + params[img_key].original_filename
      end
    end
    {:ids => ids, :attachmentpath => attachmentpath}
  end

  def self.image_path
    last_file = Dir.glob(APP_CONFIG['rma_image_path'] + "*").last
    if last_file.blank?
      path = APP_CONFIG['rma_image_path'] + "0"
    else
      counter = last_file.split("/").last.to_i
      counter = counter + 1
      path = APP_CONFIG['rma_image_path'] + counter.to_s
    end
    path
  end

  def self.separate_rma_by_type(rma)
    open_rma_ids = []
    closed_cancelled_rma_ids = []
    for i in 0..(rma["invoiceNos"].count-1) do
      if rma["rmaTypeList"][i] == "OPEN"
        open_rma_ids << i
      elsif rma["rmaTypeList"][i] == "CLOSED" || rma["rmaTypeList"][i] == "CANCELLED"
        closed_cancelled_rma_ids << i
      end
    end
    {:open_rma_ids => open_rma_ids, :closed_cancelled_rma_ids => closed_cancelled_rma_ids}
  end

  def self.data_hash_for_sending_rma_email(params,customer_number)
    ########## Creating Hash Data for sending email #########
    data_hash = {"inCustNo" => customer_number, "inSubject" => params[:subject], "inBody" => params[:body]}
    data_hash
  end

  def self.data_hash_for_rma_search(params,current_user,rma_type,page_number)
    data_hash = {"custNo" => current_user, "invoiceNo" => params[:invoice_number], "custPoNo" => params[:po_number], "partNo" => params[:part_number], "returnQty" => params[:qty], "issueFromDate" => params[:begin_date_rma], "issueToDate" => params[:end_date_rma], "rmaType" => rma_type, "lpp" => "50", "page" => page_number.to_s}
    data_hash
  end

end
