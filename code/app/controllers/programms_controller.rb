require 'open-uri'

class ProgrammsController < ApplicationController
  
  # GET /programms
  # GET /programms.json
  api :GET, '/programs'
  formats ['json']
  param :seat_number, :number, :desc => "Tawjihi Seat number",  :required => false
  param :year, :number, :desc => "Tawjihi Year, its required when you insert seat_number",  :required => false

  param :university, ["BZU", "PPU"],  :desc => "University", :required => false 
  param :branch, ["literature", "scientific"],  :desc => "Branch", :required => false 
  param :program_type, ["master", "bachelor"],  :desc => "Branch", :required => false 


  description  "This API collect all Programis form all palestainian universities"
  meta :example => <<-EOS
Return Json list
[{
"Id":"PPU2",
"title":"Accounting",
"program_type":"bachelor",
"university":"PPU",
"min-grade":75,
"branch":"literature"
},
{
"Id":"BZU2",
"title":"Software engeneering",
"program_type":"master",
"university":"BZU",
"min-grade":79,
"branch":"scientific"
}]
EOS
  def index  
	if params[:seat_number] != nil && params[:year] != nil 
		student_info=get_student_info(params[:seat_number],params[:year])

		if student_info == nil
		 render :json => {:error => "not-found"}.to_json, :status => 404
		else	
			@programs = get_programms(student_info[:grade], student_info[:section])
			render :json => @programs
		end
	elsif  params[:seat_number].nil?  && params[:year].nil?
		render :json => get_programms
	else
		render :json => {:error => "not-found student"}.to_json, :status => 404
	end
  end


  api :GET, '/programs/:id'
  param :id, String, :desc => "Program Key",  :required => true
    formats ['json']
  def show
	all_programs =get_all_programs
	all_programs.each do |fc|
		if fc['id'] ==params[:id]
			render :json => fc
		end
	end
	render :json => {:error => "not-found"}.to_json, :status => 404
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
	def get_all_programs
		if Rails.cache.exist?('cache_progs')
			all_programs = Rails.cache.read('cache_progs')
		else
			bz_programms = get_bzu_program;
			pp_programms = get_ppu_programs
			Rails.cache.write('cache_progs', pp_programms + bz_programms, :unless_exist => true, :expires_in => 15.minutes)
			return  pp_programms + bz_programms
		end
	end

	def get_programms (grade = 0 , branch = nil )
		all_programs  = get_all_programs
		programs = []
		all_programs.each do |fc|
			if ( grade == 0 or grade.to_f > fc['mingrade'].to_f )  && (fc['branch'] == branch or branch == nil)
				programs << fc
			end
		end
		programs
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def programm_params
      params.require(:programm).permit(:name, :university, :mingrade, :description)
    end
	def get_bzu_program 
			response = open('http://bzuprograms.herokuapp.com/programs.json').read
			response = JSON.parse response
			response.class
			program = []
			  response.each do |fc|
			    fc['university']='BZU'
				fc['id'] = 'BZU'+fc['id'].to_s
				fc['url']=""
				program << fc
			  end
			program
	end
	def get_student_info (seat_number,year)
		#client = Savon::Client.new("http://ec2-35-166-183-83.us-west-2.compute.amazonaws.com/?wsdl")
		client = Savon.client(wsdl: "http://ec2-35-166-183-83.us-west-2.compute.amazonaws.com/?wsdl")
		response = client.call(:get_student_data, message: { "SeatNo" => seat_number ,  "Year" => year })
		
		#response.hash[:envelope][:body][:get_student_data_response][:return][:item][:name]  
		if response.hash.size > 0
			return response.hash[:envelope][:body][:get_student_data_response][:return][:item]
		end
		return nil
		#client.wsdl.soap_actions
	#	response = client.request :web, :getStudentData, body: { "SeatNo" => "11111102" ,  "Year" => "2016"  }

	end
	
	def get_ppu_programs 

			url = URI.parse('http://151.80.134.50/drupal-8//index.php/graphql?=&query={%0A%20nodeQuery(type%3A%20%22Program%22)%20{%0A%20...%20on%20EntityNodeProgram%20{%0A%20title%0A%0A%20nid%0A%20minGrade%0A%20programType%0A%20branch%0A%20}%0A%20}%0A}%0A')
			request = Net::HTTP.get(url )
			programs = []
			#return programs
			requestjson = JSON.parse(request)
			#return request['data']['nodeQuery']
			requestjson['data']['nodeQuery'].each do |fc|
				prg=Hash.new
				prg['id']='PPU'+fc['nid'].to_s
				prg['title']=fc['title']
				prg['description']=''
				prg['branch']=fc['branch']
				prg['mingrade']=fc['minGrade']
				prg['program_type']=fc['programType']
				prg['university']='PPU'

				programs << prg
			end
			return programs
	end

end
