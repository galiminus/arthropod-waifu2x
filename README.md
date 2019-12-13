# Arthropod-waifu2x

## Installation

```
gem install arthropod_waifu2x
```

## Usage

Just run it with the required arguments.
```shell
$ arthropod_waifu2x -h

Usage: arthropod_waifu2x [options]
    -q, --queue [string]             SQS queue name
    -i, --access-key-id [string]     AWS access key ID, default to the AWS_ACCESS_KEY_ID environment variable
    -k, --secret-access-key [string] AWS secret access key, default to the AWS_SECRET_ACCESS_KEY environment variable
    -r, --region [string]            AWS region, default to the AWS_REGION environment variable
    -w, --waifu [string]             Waifu2X install directory, default to /opt/waifu2x
```

Example of client side call:
```ruby
result = Arthropod::Client.push(queue_name: "waifu2x", body: {
  image_url: "https://s3-#{ENV['S3_REGION']}.amazonaws.com/#{ENV['S3_BUCKET']}/#{medium.temporary_key}",
  root_dir: Digest::SHA1.hexdigest("#{ENV["SECURE_UPLOADER_KEY"]}#{medium.uuid}").insert(3, '/'),
  aws_access_key_id: ENV['S3_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
  region: ENV['S3_REGION'],
  endpoint: ENV['S3_ENDPOINT'],
  host: ENV['S3_HOST'],
  bucket: ENV['S3_BUCKET'],
})
```

* `image_url`: the URL of the image you want to scale
* `root`: the destination directory in your bucket
* `aws_access_key_id`: an AWS access key to access your bucket
* `aws_secret_access_key`:  an AWS secret access key to access your bucket
* `region`: the region of your bucket
* `endpoint`: the endpoint of your S3 instance if you have one (useful for Minio)
* `host`: the host of your S3 instance if you have one (useful for Minio)
* `bucket`: your bucket name

The result object is a follow.

```ruby
{
  key: "[string]",
}
```

* `key`: the key the resulting image

*Both the input and output are very opiniated and follow my needs*
