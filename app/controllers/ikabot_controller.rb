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

    events = client.parse_events_from(body)

    events.each { |event|
      if event.message['text'].present?
        place = event.message['text']
        result = `curl -X POST https://spla2.yuu26.com/'#{place}'/now `
      else
        result = `curl -X POST https://spla2.yuu26.com/regular/now `
      end

      hash_result = JSON.parse result #レスポンスが文字列なのでhashにパースする
      info = hash_result["result"] 

      rule_name = info["rule"] #ルール名
      map_name = info["maps"] #店の名前
      open_time = info["start"] #空いている時間
      close = info["end"] #おしまい

      response = "【バトル】" + rule_name + "\n" + "【マップ】" + map_name + "\n" + "【OPEN時間】" + open_time + "\n" + close + "\n" 

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
             type: 'text',
             text: result
           }
           client.reply_message(event['replyToken'], message)

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

