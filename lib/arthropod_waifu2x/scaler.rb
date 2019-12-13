require 'shellwords'
require 'json'
require 'securerandom'
require 'fog/aws'
require 'pathname'

module ArthropodWaifu2x
  class Scaler
    attr_reader :image_url, :aws_access_key_id, :aws_secret_access_key, :region, :endpoint, :host, :bucket, :root_dir, :waifu

    def initialize(image_url:, aws_access_key_id:, aws_secret_access_key:, region:, endpoint:, host:, bucket:, root_dir:, waifu:)
      @image_url = image_url
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key
      @region = region
      @endpoint = endpoint
      @host = host
      @bucket = bucket
      @root_dir = root_dir
      @waifu = waifu
    end

    def perform!
      Dir.mktmpdir do |wdir|
        @wdir = wdir

        download_input!

        {
          key: perform_scaling!
        }
      end
    end

    def download_input!
      call_command("curl #{Shellwords.escape(image_url)} -s -o #{input_path}")
    end

    def perform_scaling!
      call_command("convert #{input_path} #{converted_path}")
      Dir.chdir waifu do
        call_command("th #{waifu_bin} -m scale -i #{converted_path} -o #{scaled_path}")
      end
      "#{root_dir}/#{SecureRandom.uuid}#{File.extname(image_url)}".tap do |key|
        upload(scaled_path, key)
      end
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

    def storage
      @storage ||= Fog::Storage.new({
        provider:              'AWS',
        aws_access_key_id:     aws_access_key_id,
        aws_secret_access_key: aws_secret_access_key,
        region:                region,
        endpoint:              endpoint,
        host:                  host,
        path_style:            true
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
