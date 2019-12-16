require 'shellwords'
require 'json'
require 'securerandom'
require 'fog/aws'
require 'pathname'

module ArthropodWaifu2x
  class Scaler
    class InvalidOptions < StandardError; end

    attr_reader :image_url, :access_key_id, :secret_access_key, :region, :bucket, :waifu, :scale, :noise_level

    def initialize(image_url:, access_key_id:, secret_access_key:, region:, bucket:, waifu:, scale: true, noise_level: nil)
      @image_url = image_url
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @region = region
      @bucket = bucket
      @waifu = waifu
      @scale = scale
      @noise_level = noise_level
    end

    def perform!
      Dir.mktmpdir do |wdir|
        @wdir = wdir

        download_input!

        {
          url: perform_scaling!,
          noise_level: noise_level,
          scale: scale
        }
      end
    end

    def download_input!
      call_command("curl #{Shellwords.escape(image_url)} -s -o #{input_path}")
    end

    def perform_scaling!
      call_command("convert #{input_path} #{converted_path}")
      Dir.chdir waifu do
        call_command("th #{waifu_bin} #{model_options} -i #{converted_path} -o #{scaled_path}")
      end

      upload(scaled_path, "#{SecureRandom.uuid}.png")
    end

    def waifu_bin
      Shellwords.escape(Pathname.new(waifu).join("waifu2x.lua").to_s)
    end

    def input_path
      Shellwords.escape("#{@wdir}/input")
    end

    def converted_path
      Shellwords.escape("#{@wdir}/converted.png")
    end

    def scaled_path
      Shellwords.escape("#{@wdir}/scaled.png")
    end

    def call_command(command)
      system(command, out: File::NULL, err: File::NULL)
      raise if $?.to_i != 0
    end

    def model_options
      if noise_level && scale
        "-m noise_scale -noise_level #{Shellwords.escape(noise_level)}"
      elsif scale
        "-m scale"
      elsif noise_level
        "-m noise -noise_level #{Shellwords.escape(noise_level)}"
      else
        raise InvalidOptions
      end
    end

    def storage
      @storage ||= Fog::Storage.new({
        provider:              'AWS',
        aws_access_key_id:     access_key_id,
        aws_secret_access_key: secret_access_key,
        region:                region,
      })
      @storage.directories.get(bucket)
    end

    def upload(path, key)
      open(path) do |file|
        storage.files.create({
          key: key,
          body: file,
          public: true
        })
      end.public_url
    end
  end
end
