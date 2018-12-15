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
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if text_params == "ナワバリマッチ" then
          message = {
            type: 'text',
            text: "${event.message['text']}いいね！" 
          }
          client.reply_message(event['replyToken'], message)

          elsif text_params  == "ガチマッチ" then
            message = {
              type: 'text',
              text: "${event.message['text']}はガチエリア、ガチヤグラ、ガチホコバトル、ガチアサリだね"
            }
          client.reply_message(event['replyToken'], message)

          elsif text_params  == "サーモンラン" then
            message = {
              type: 'text',
              text: "${event.message['text']}はバイト"
            }

          else 
            message = {
              type: 'text'
              text: event.message['text']
            }
          client.reply_message(event['replyToken'], message)
          end

        when Line::Bot::Event::MessageType::Sticker
          message = {
            type: 'sticker',
            packageId: event.message['packageId'],
            stickerId: event.message['stickerId']
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

