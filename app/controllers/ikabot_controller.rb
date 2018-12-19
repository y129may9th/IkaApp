class IkabotController < ApplicationController
    require 'line/bot'
    require 'net/http'
    require 'json'
    

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

    if text_params == "ナワバリ" then
      rule = "regular/now"
    elsif text_params == "ガチマッチ" then
      rule = "gachi/now"
    elsif text_params == "サーモンラン" then
      rule = "coop"
    end

    spla2 = "https://spla2.yuu26.com/#{rule}"
    uri = URI.parse(spla2)
    res = Net::HTTP.get(uri)
    json = JSON.parse(res)

    result = json["result"][0]
    rule = result["rule"]
    map1 = result["maps"][0]
    map2 = result["maps"][1]
    image1 = result["maps_ex"][0]["image"]
    image2 = result["maps_ex"][1]["image"]

    #response = "【バトル】" + "\n" + rule + "\n" + "【マップ】" + "\n" + map1 + "\n" + "\n" + map2 + "\n" 

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          messages = {
            "type": "bubble",
            "hero": {
              "type": "image",
              "url": image1,
              "size": "full",
              "aspectRatio": "20:13",
              "aspectMode": "cover"
            },
            "body": {
              "type": "box",
              "layout": "vertical",
              "spacing": "md",
              
              "contents": [
                {
                  "type": "text",
                  "text": "レギュラーマッチ",
                  "size": "xl",
                  "weight": "bold"
                },
                 {
                  "type": "text",
                  "text": "mm/dd hh:mm-hh:mm",
                  "wrap": true,
                  "color": "#aaaaaa",
                  "size": "xxs"
                },
                {
                  "type": "box",
                  "layout": "vertical",
                  "spacing": "sm",
                  "contents": [
                    {
                      "type": "box",
                      "layout": "horizontal",
                      "contents": [
                        {
                          "type": "image",
                          "url": image1
                        },
                        {
                          "type": "text",
                          "text": map1,
                          "weight": "bold",
                          "margin": "sm",
                          "flex": 0,
                          "gravity": "center"
                        },
                        {
                          "type": "text",
                          "text": "400kcl",
                          "size": "sm",
                          "align": "end",
                          "color": "#aaaaaa"
                        }
                      ]
                    },
                    {
                      "type": "box",
                      "layout": "horizontal",
                      "contents": [
                        {
                          "type": "image",
                          "url": image2
                        },
                        {
                          "type": "text",
                          "text": map2,
                          "weight": "bold",
                          "margin": "sm",
                          "flex": 0,
                          "gravity": "center"
                        },
                        {
                          "type": "text",
                          "text": "550kcl",
                          "size": "sm",
                          "align": "end",
                          "color": "#aaaaaa"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          }
          # messages = [
          #   {
          #     type: 'text',
          #     text: response
          #   },
          #   {
          #     type: 'image',
          #     originalContentUrl: image1,
          #     previewImageUrl: image1
          #   },
          #   {
          #     type: 'image',
          #     originalContentUrl: image2,
          #     previewImageUrl: image2
          #   }
          # ]
           client.reply_message(event['replyToken'], messages)

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

