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
      spla2 = "https://spla2.yuu26.com/#{rule}"
    uri = URI.parse(spla2)
    res = Net::HTTP.get(uri)
    json = JSON.parse(res)

    result = json["result"][0]
    rule = result["rule"]
    map1 = result["maps"][0]
    map2 = result["maps"][1]
    map1_image = result["maps_ex"][0]["image"]
    map2_image = result["maps_ex"][1]["image"]
    response = "【バトル】" + "\n" + rule + "\n" + "【マップ】" + "\n" + map1 + "\n" + map2 

    elsif text_params == "ガチマッチ" then
      rule = "gachi/now"
      spla2 = "https://spla2.yuu26.com/#{rule}"
    uri = URI.parse(spla2)
    res = Net::HTTP.get(uri)
    json = JSON.parse(res)

    result = json["result"][0]
    rule = result["rule"]
    map1 = result["maps"][0]
    map2 = result["maps"][1]
    map1_image = result["maps_ex"][0]["image"]
    map2_image = result["maps_ex"][1]["image"]
    response = "【バトル】" + "\n" + rule + "\n" + "【マップ】" + "\n" + map1 + "\n" + map2 

    elsif 
    text_params == "サーモンラン" 
      rule = "coop"
      spla2 = "https://spla2.yuu26.com/#{rule}"
      
    uri = URI.parse(spla2)
    res = Net::HTTP.get(uri)
    json = JSON.parse(res)

    result = json["result"][0]
    stage = result["stage"]["name"]
    stage_image = result["stage"]["image"]
    buki1 = result["weapons"][0]["name"]
    buki2 = result["weapons"][1]["name"]
    buki3 = result["weapons"][2]["name"]
    buki4 = result["weapons"][3]["name"]
    buki1_image = result["weapons"][0]["image"]
    buki2_image = result["weapons"][1]["image"]
    buki3_image = result["weapons"][2]["image"]
    response_coop = "【サーモンラン】" + "\n" + stage + "【ブキ】" + "\n" + buki1 + "\n" + buki2 + "\n" + buki3 + "\n" + buki4 

    else 
      comment = "「ナワバリ」\n「ガチマッチ」\n「サーモンラン」\n のいずれかの単語を送信してください"
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if text_params == "ナワバリ"
            messages = [
            {
              type: 'text',
              text: response
            },
            {
              type: 'image',
              originalContentUrl: map1_image,
              previewImageUrl: map1_image
            },
            {
              type: 'image',
              originalContentUrl: map2_image,
              previewImageUrl: map2_image
            }
          ]
            client.reply_message(event['replyToken'], messages)
            
          elsif text_params == "ガチマッチ"
            messages = [
            {
              type: 'text',
              text: response
            },
            {
              type: 'image',
              originalContentUrl: map1_image,
              previewImageUrl: map1_image
            },
            {
              type: 'image',
              originalContentUrl: map2_image,
              previewImageUrl: map2_image
            }
          ]
            client.reply_message(event['replyToken'], messages)
              
        　  elsif text_params == "サーモンラン" 
              messages = [
              {
                type: 'text',
                text: response_coop
              },
              {
                type: 'image',
                originalContentUrl: stage_image,
                previewImageUrl: stage_image
              },
              {
                type: 'image',
                originalContentUrl: buki1_image,
                previewImageUrl: buki1_image
              },
              {
                type: 'image',
                originalContentUrl: buki2_image,
               previewImageUrl: buki2_image
               },
              {
                type: 'image',
                originalContentUrl: buki3_image,
                previewImageUrl: buki3_image
              }
            ]
              client.reply_message(event['replyToken'], messages)
            else
              message = {
                       type: 'text',
                       text: comment
                     }
              client.reply_message(event['replyToken'], messages)
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

