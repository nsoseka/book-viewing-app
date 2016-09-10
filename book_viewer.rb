require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

configure :development do
  enable :reloader
end

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  # break every chapter into seperate paragraphs
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |par, index|
      "<p id='paragraph#{index + 1}'>#{par}</p>"
    end.join
  end

  def query_matcher(query)
    @results = []
    @paragraphs = []
    if !query.nil?
      # bring out chapters that have query
      (1..12).to_a.each_with_index do |chap_num, index|
        chapter = File.read("data/chp#{chap_num}.txt")
        # bring out paragraphs that have query
        if chapter.match(query)
          chapter.split("\n\n").each_with_index do |par, idx|
            @paragraphs << [par, idx] if par.match(query)
          end
        # store chapters and their index with paragraphs and index
        @results << [@contents[index], index, @paragraphs]
        end
        @paragraphs = []
      end
    end
    @results
  end

  # highlight search text(query) in its paragraph
  def high_lighter(par, string, match, index)
    idx = "#{index + 1}"
    par.gsub(string, "<a href='/chapters/#{match + 1}#paragraph#{idx}'><strong>#{string}</strong></a>")
  end

end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  
  erb :home
end

get "/chapters/:number" do
  if (1..12).to_a.include?(params[:number].to_i)
    number = params[:number]
    @title = "Chapter #{number}"
    @chapter = File.read("data/chp#{number}.txt")

    page_index = number.to_i - 1
    @chapter_title = @contents[page_index]

    erb :chapter
  else
    redirect '/'
  end
end

get '/search' do
  erb :search
end

# redirect all unknown paths to the home path
not_found do
  redirect "/"
end
