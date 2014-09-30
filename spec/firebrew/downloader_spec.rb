require 'spec_helper'
require 'stringio'
require 'digest/md5'
require 'webmock/rspec'
require 'os'

module Firebrew
  describe Downloader do
    describe '::normalize_uri(uri)' do
      subject do
        Downloader.normalize_uri(self.uri)
      end
      
      context 'when the uri contained spaces and unicode characters etc' do
        let(:uri){'http://www.example.com/a b/あ.html'}
        let(:expected_uri){URI.parse('http://www.example.com/a%20b/%E3%81%82.html')}
        
        it 'should be encoded by percent-encoding' do
          is_expected.to eq(self.expected_uri)
        end
      end
      
      context 'when the uri path was empty' do
        let(:uri){'http://www.example.com'}
        it 'path should be "/"' do
          expect(subject.path).to eq('/')
        end
      end
      
      context 'when the uri scheme was "http"' do
        let(:uri){'http://www.example.com/a/b.html'}
        let(:expected_uri){URI.parse('http://www.example.com/a/b.html')}
        it { is_expected.to eq(self.expected_uri) }
      end
      
      context 'when the uri scheme was "https"' do
        let(:uri){'https://www.example.com/a/b.html'}
        let(:expected_uri){URI.parse('https://www.example.com/a/b.html')}
        it { is_expected.to eq(self.expected_uri) }
      end
      
      context 'when the uri scheme was "file"' do
        if OS.windows? then
          let(:uri){'file:///C:/a/b.html'}
          let(:expected_uri){URI.parse('file:///C:/a/b.html')}
        else
          let(:uri){'file:///a/b.html'}
          let(:expected_uri){URI.parse('file:///a/b.html')}
        end
        it { is_expected.to eq(self.expected_uri) }
      end
      
      context 'when the uri scheme was empty' do
        if OS.windows? then
          let(:uri){'C:/a/b.html'}
          let(:expected_uri){URI.parse('file:///C:/a/b.html')}
        else
          let(:uri){'/a/b.html'}
          let(:expected_uri){URI.parse('file:///a/b.html')}
        end
        
        it 'should convert a file scheme' do
          is_expected.to eq(self.expected_uri)
        end
        
        context 'when the path was relative' do
          let(:uri){'./a/b.html'}
          
          if OS.windows? then
            let(:expected_uri){URI.parse("file:///#{Dir.pwd}/a/b.html")}
          else
            let(:expected_uri){URI.parse("file://#{Dir.pwd}/a/b.html")}
          end
          
          it 'should be an absolute path from the current dir' do
            is_expected.to eq(self.expected_uri)
          end
        end
      end
      
      context 'when the uri scheme was not "http", "https" and "file"' do
        let(:uri){'hoge:///a/b/c'}
        
        it 'should throw Firebrew::NetworkError' do
          expect{subject}.to raise_error(Firebrew::NetworkError, "Don't support the scheme: hoge")
        end
      end
    end
    
    describe '#initialize(uri, out[, progress_options]) -> #exec()' do
      before do
        self.before_callback[]
        Downloader.new(self.uri, self.out).exec
        self.out.rewind
      end
      
      let(:before_callback){->{}}
      let(:uri){''}
      let(:out){StringIO.new}
      
      context 'when the uri scheme was "file"' do
        let(:uri){'./spec/fixtures/firefox/extension/unpack_false.xpi'}
        
        it 'should download a content which is referenced by the uri' do
          md5, path = File.read(self.uri.pathmap('%X.md5')).split(/\s+/)
          expect(Digest::MD5.hexdigest(self.out.read)).to eq(md5)
        end
      end
      
      context 'when the uri scheme was "http" or "https"' do
        let(:before_callback){->{
          response = File.open(self.response_path, 'rb').read
          stub_request(:head, 'www.example.com').to_return(headers: {
            'Content-Length'=> response.size
          })
          stub_request(:get, 'www.example.com').to_return(body: response)
        }}
        
        let(:uri){'http://www.example.com'}
        let(:response_path){'./spec/fixtures/firefox/extension/unpack_false.xpi'}
        
        it 'should download a content which is referenced by the uri' do
          md5, path = File.read(self.response_path.pathmap('%X.md5')).split(/\s+/)
          expect(Digest::MD5.hexdigest(self.out.read)).to eq(md5)
        end
        
        context 'when the response status code was 302' do
          let(:before_callback){->{
            response = File.open(self.response_path, 'rb').read
            stub_request(:head, 'www.example.com').to_return(status: 302, headers: {
              'Location'=> 'http://dl.example.com/'
            })
            stub_request(:head, 'dl.example.com').to_return(headers: {
              'Content-Length'=> response.size
            })
            stub_request(:get, 'dl.example.com').to_return(body: response)
          }}
          
          let(:uri){'http://www.example.com'}
          let(:response_path){'./spec/fixtures/firefox/extension/unpack_false.xpi'}
          
          it 'should download a content which is referenced by the uri' do
            md5, path = File.read(self.response_path.pathmap('%X.md5')).split(/\s+/)
            expect(Digest::MD5.hexdigest(self.out.read)).to eq(md5)
          end
        end
      end
    end
  end
end
