class IkabotController < ApplicationController
    require 'line/bot'
    
    # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    text_params = params["events"][0]["message"]["text"] #メッセージイベントからテキストの取得

    events = client.parse_events_from(body)
    events.each { |event|
      if event.message['text'].present?
        place = event.message['text']
        result = https://spla2.yuu26.com/'#{place}'/now  
      else
        result = https://spla2.yuu26.com/regular/now #, https://spla2.yuu26.com/gachi/now , https://spla2.yuu26.com/league/now 
      end

      rule_name = rule #ルール名
      map_name = maps #店の名前
      open_time = start #空いている時間
      close = end #定休日

      response = "【バトル】" + rule_name + "\n" + "【マップ】" + map_name + "\n" + "【OPEN時間】" + open_time + "\n" + close + "\n" 

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
             type: 'text',
             text: response
           }
           client.reply_message(event['replyToken'], message)
         end

          end

        when Line::Bot::Event::MessageType::Sticker
          message = {
            type: 'sticker',
            packageId: event.message['packageId'],
            stickerId: event.message['stickerId']
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end

