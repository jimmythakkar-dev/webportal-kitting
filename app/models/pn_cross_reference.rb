class PnCrossReference
  # Method to extract Assist Code
=begin
 CF BASE
<cfset ASSIST1=REReplaceNoCase(XPartNo1,"[A-Z]+[0-9]*", "")>
	<cfset ASSIST1LEN=LEN(XPartNo1)-LEN(ASSIST1)>

		<cfif ASSIST1LEN gt 0 >
			<cfset ASSIST_DOCID=LEFT(XPartNo1,ASSIST1LEN)>
		<cfelse>
			<cfset ASSIST_DOCID="" >
		</cfif>
=end
  def self.assist part_no
    replaced_num = part_no.chr.numeric? ?  part_no.gsub(/[A-Z]+[0-9]*/,"") : part_no.gsub(/^[A-Z0-9]*/,"")
    str_length = part_no.length - replaced_num.length
    if str_length > 0
      string = part_no[0...str_length]
    else
      string = ""
    end
  end
end
