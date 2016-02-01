Pod::Spec.new do |s|
  s.name     = "MashServer"
  s.version  = "0.0.1"
  s.license  = "New BSD"
  s.authors  = { "Daniel Hsu" => "dannyighsu@gmail.com" }
  s.homepage = "https://mashwith.me"
  s.source = { :git => "https://github.com/dannyighsu/Mash.git" }
  s.summary = "Mash server."

  s.ios.deployment_target = "8.3"

  # Run protoc with the Objective-C and gRPC plugins to generate protocol messages and gRPC clients.
  s.prepare_command = "protoc -I . --plugin=protoc-gen-grpc=/usr/local/bin/grpc_objective_c_plugin --objc_out=. --grpc_out=. ./protos/*.proto"

  s.subspec "Messages" do |ms|
    ms.source_files = "protos/*.pbobjc.{h,m}"
    ms.header_mappings_dir = "."
    ms.requires_arc = false
    ms.dependency "Protobuf", "~> 3.0.0-alpha-3"
  end

  s.subspec "Services" do |ss|
    ss.source_files = "protos/*.pbrpc.{h,m}"
    ss.header_mappings_dir = "."
    ss.requires_arc = true
    ss.dependency "gRPC", "~> 0.5"
    ss.dependency "#{s.name}/Messages"
  end
end
