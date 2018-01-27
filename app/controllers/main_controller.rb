require 'open-uri'
class MainController < ApplicationController
  @@stopsList = Hash.new
  @@sizeTable = 10
  @@maksFavouriteStop = 5
  @@minPossibleSize = 5
  @@maksPossibleSize = 20

  @@test = 0
  @@favStop = Array.new
  def index
    if(cookies[:favouriteStop].blank?||cookies[:favouriteStop].split('&').size==0)
      cookies.permanent[:favouriteStop] = Array.new
    end
    if(cookies[:sizeArrivalTable].blank?||cookies[:favouriteStop]!="")
      cookies.permanent[:sizeArrivalTable] = @@sizeTable
    end
    liczba = number_or_nil(cookies[:sizeArrivalTable])
    if(liczba!=NIL&&liczba>=@@minPossibleSize&&liczba<=@@maksPossibleSize)
      @@sizeTable = liczba
    end
    @@favStop = cookies[:favouriteStop].split('&')
    @shortName = ""
    @size = @@sizeTable
    jsonStopsList = NIL
    begin
      jsonStopsList = JSON.load(open("http://www.ttss.krakow.pl/internetservice/geoserviceDispatcher/services/stopinfo/stops?left=-648000000&bottom=-324000000&right=648000000&top=324000000"))["stops"]
    rescue => ex
     case ex
       when OpenURI::HTTPError
         puts "HTTPError: "+ex.to_s
       when SocketError
         puts "SocketError: "+ex.to_s
       else
         raise e
     end
    end
    @@stopsList = Hash.new
    @@stopsList[""] = ""
    if(jsonStopsList!=NIL)
      for element in jsonStopsList
        @@stopsList[element["shortName"]]=element["name"]
      end
    end
    @@stopsList = Hash[@@stopsList.sort_by {|k,v| v}]

    if(params[:stop])

      @shortName = params[:stop]
    end
    @arrivalList = generateArrival(@shortName)
  end

  def getStopsList
    @@stopsList
  end
  helper_method :getStopsList

  def getSizeArrivalTable
    @@sizeTable
  end
  helper_method :getSizeArrivalTable

  def getMaksFavStop
    @@maksFavouriteStop
  end
  helper_method :getMaksFavStop

  def getFavouriteStops
    @@favStop
  end
  helper_method :getFavouriteStops

  def getMinPossibleSize
    @@minPossibleSize
  end
  helper_method :getMinPossibleSize

  def getMaksPossibleSize
    @@maksPossibleSize
  end
  helper_method :getMaksPossibleSize
  def refresh_table
    @size = @@sizeTable
    @shortName = ""
    if(params[:st])
      @shortName = params[:st]
    end
    @arrivalList = generateArrival(@shortName)
    render :partial => 'arrivalTable'
  end
  def addFavourite
    if(params[:shortName]&&params[:shortName]!="")
      if(isFavourite(params[:shortName])==false&&@@favStop.size<@@maksFavouriteStop+1)
        @@favStop.push(params[:shortName])
        cookies.permanent[:favouriteStop]=@@favStop
      end
      redirect_to root_path+"?utf8=%E2%9C%93&stop="+params[:shortName]

    else
      redirect_to root_path
    end
  end
  def delFavourite
    if(params[:shortName]&&params[:shortName]!="")
      i=0
      while i<@@favStop.size
        if(@@favStop[i]==params[:shortName])
          @@favStop.delete_at(i)
        end
        i+=1
      end
      cookies.permanent[:favouriteStop]=@@favStop
      if(params[:backStop]&&params[:backStop]!="")
        redirect_to root_path+"?utf8=%E2%9C%93&stop="+params[:backStop]
      else
        redirect_to root_path
      end
    else
      redirect_to root_path
    end

  end
  def changeMaxSize
    if(params[:size]&&params[:size]!="")
      liczba = number_or_nil(params[:size])
      if(liczba!=NIL&&liczba>=@@minPossibleSize&&liczba<=@@maksPossibleSize)
        @@sizeTable = liczba
        cookies.permanent[:sizeArrivalTable] = liczba
      end

    end
    if(params[:backStop]&&params[:backStop]!="")
      redirect_to root_path+"?utf8=%E2%9C%93&stop="+params[:backStop]
    else
      redirect_to root_path
    end
  end
  private
  def number_or_nil(string)
    Integer(string || '')
    rescue ArgumentError
    nil
  end
  private
  def isFavourite(shortName)
    i = 0
    while i<@@favStop.size do
      if(shortName == @@favStop[i])
        return true
      end
      i+=1
    end
    return false
  end
  private
  def generateArrival(shortName)
    arrival = NIL
    if(shortName&&shortName!="")
      begin
        arrival = JSON.load(open("http://www.ttss.krakow.pl/internetservice/services/passageInfo/stopPassages/stop?stop="+shortName))["actual"]
        if(arrival.size <= @@sizeTable)
          @size = arrival.size
        end
      rescue => ex
        case ex
          when OpenURI::HTTPError
            puts "HttpError: "+ex.to_s
          when SocketError
            puts "SocketError: "+ex.to_s
        end
          @size = 0
      end
    else
      puts "Brak parametru"

    end
    return arrival
  end
end
