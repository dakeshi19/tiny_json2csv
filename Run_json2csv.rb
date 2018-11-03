# -*- coding: utf-8 -*-
require 'json'
require './FlatkeyHashProvider.rb'

# jsonをcsvに変換する小手先のツール

# 本プログラム最下部に指定したプロパティに該当するプロパティを抜き出す
keys = DATA.read.split("\n")

#引数が無い場合は、ヘッダー出力して終了
if ARGV.size == 0 then
  keys.each{|k|
    print k
    print "\t"
  }
  print "\r\n"
  exit
end

#json読み込み
json = JSON.parse(File.open(ARGV[0]).read)

fhc = FlatkeyHashProvider.new(json)
keys.each{|k|
  v = fhc.get_json_value_on(k)
  v = fhc.get_json_value_on(k).gsub(/\R/,'★改行★')  if v.instance_of?(String) #json中の改行は★改行★に置き換える。
  print v
  print "\t"
}
print "\r\n"

#下記に「a.b.c.1.d」の形式で指定された項目の値を出力。指定形式の説明は、FlatkeyHashProviderクラスの説明を参照のこと。
__END__
name
price
shipTo.zip
foo.1.a
foo.1
foo.1.c
