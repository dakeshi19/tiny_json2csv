# -*- coding: utf-8 -*-
#require 'json'

# jsonから変換したハッシュの特定のプロパティに、get_json_value_on('a.b.c')のように、ドット区切りでプロパティの階層を指定してアクセスする。
# rubyのネストされたハッシュへのアクセスを今回の要件での取り回しを考えて、階層の深さを意識せず値を取得できるようにするためのユーティリティ。
# 配列の最初からN番目の要素については、'a.b.5'のようにすると5番目(添字としては4)の要素にアクセスできる。
# @example
#    fhp = FlatkeyHashProvider.new(srcjson_hash)
#    puts fhp.get_json_value_on('a.b.c')
#      → a.b.cの値が文字列"aaaa"なら、"aaaa"が出力される。
class FlatkeyHashProvider
  #入力json情報(rubyのHash化済み)を引数に受け取り初期化する。
  def initialize(json_hash)
    @hash = Marshal.load(Marshal.dump(json_hash)) #念のため深いコピーにしておく。
  end

  #このクラスのコンストラクターが受け取ったjsonのHashオブジェクトに対し、flat_key(a.b.5...の形式)で指定されたパスのHash実際の値を返す。
  #なお、該当のプロパティ自体が存在しない場合は空の文字列を返す。
  def get_json_value_on(flat_key)
    props = flat_key.split('.')
    h = dig(props, @hash)
    if h.instance_of?(String)  then
      return h.gsub(/\t/,'')    # 今回は含まれない想定だが、タブは除去する。 ※項目中の改行はこのメソッドをコールする側で必要なら置換等する前提
    end
    return h
  end

  #内部処理：指定のプロパティを1段ずつ掘り下げて再帰的に取得する。
  def dig(props,json_child)
    
    key = props.shift
    idx = 0
    if key =~ /^\d+$/ then  # 数字とみなせる場合は配列の指定として解釈する。また、配列の添字に合わせるため -1する
      idx = key.to_i 
      key = idx - 1
    end
    #値をリターンする条件に該当する場合は値を返す(下記）
    return "" if json_child.instance_of?(Array) && ( json_child.size == 0 || idx > json_child.size )  # 配列が空の場合、もしくは指定の値が配列のサイズより大きい場合、空の文字列を返す
    return "" if json_child.instance_of?(Hash)  && json_child.has_key?(key) == false #この階層に指定のプロパティのキーが存在しない場合、空の文字列を返す
    return json_child[key] if props.size == 0  # 指定の値に到達したのでその値を返す
    #値を取得するために再帰digする
    return dig(props,json_child[key])
  end

  #2017/6/25時点未使用
  def replace_value_on(flat_key,with_obj)
    props = flat_key.split('.')
    h = dig(props,@hash)
    h.replace(with_obj)
  end
  alias_method :replace, :replace_value_on

  def get_hash()
      return @hash
  end

end



