#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe Chef::Provider::HttpRequest do
  before(:each) do
    @node = Chef::Node.new
    @run_context = Chef::RunContext.new(@node, {})
    
    @new_resource = Chef::Resource::HttpRequest.new('adam')
    @new_resource.name "adam"
    @new_resource.url "http://www.opscode.com"
    @new_resource.message "is cool"

    @provider = Chef::Provider::HttpRequest.new(@new_resource, {})
  end
  
  describe "load_current_resource" do  
  
    it "should set up a Chef::REST client, with no authentication" do
      Chef::REST.should_receive(:new).with(@new_resource.url, nil, nil)
      @provider.load_current_resource
    end
  end

  describe "when making REST calls" do
    before(:each) do
      @rest = mock("Chef::REST", :create_url => "http://www.opscode.com", :run_request => "you made it!" )
      @provider.rest = @rest
    end

    describe "action_get" do  
      it "should create the url with a message argument" do
        @rest.should_receive(:create_url).with("#{@new_resource.url}?message=#{@new_resource.message}")
        @provider.action_get
      end
  
      it "should inflate a message block at runtime" do
        @new_resource.stub!(:message).and_return(lambda { "return" })
        @rest.should_receive(:create_url).with("#{@new_resource.url}?message=return")
        @provider.action_get
      end
  
      it "should run a GET request" do
        @rest.should_receive(:run_request).with(:GET, @rest.create_url, {}, false, 10, false)
        @provider.action_get
      end
  
      it "should update the resource" do
        @new_resource.should_receive(:updated=).with(true)
        @provider.action_get
      end
    end

    describe "action_put" do  
      it "should create the url" do
        @rest.should_receive(:create_url).with("#{@new_resource.url}")
        @provider.action_put
      end
  
      it "should run a PUT request with the message as the payload" do
        @rest.should_receive(:run_request).with(:PUT, @rest.create_url, {}, @new_resource.message, 10, false)
        @provider.action_put
      end
  
      it "should inflate a message block at runtime" do
        @new_resource.stub!(:message).and_return(lambda { "return" })
        @rest.should_receive(:run_request).with(:PUT, @rest.create_url, {}, "return", 10, false)    
        @provider.action_put
      end
  
      it "should update the resource" do
        @new_resource.should_receive(:updated=).with(true)
        @provider.action_put
      end
    end

    describe "action_post" do  
      it "should create the url" do
        @rest.should_receive(:create_url).with("#{@new_resource.url}")
        @provider.action_post
      end
  
      it "should run a PUT request with the message as the payload" do
        @rest.should_receive(:run_request).with(:POST, @rest.create_url, {}, @new_resource.message, 10, false)
        @provider.action_post
      end
  
      it "should inflate a message block at runtime" do
        @new_resource.stub!(:message).and_return(lambda { "return" })
        @rest.should_receive(:run_request).with(:POST, @rest.create_url, {}, "return", 10, false)    
        @provider.action_post
      end
  
      it "should update the resource" do
        @new_resource.should_receive(:updated=).with(true)
        @provider.action_post
      end
    end

    describe "action_delete" do  
      it "should create the url" do
        @rest.should_receive(:create_url).with("#{@new_resource.url}")
        @provider.action_delete
      end
  
      it "should run a DELETE request" do
        @rest.should_receive(:run_request).with(:DELETE, @rest.create_url, {}, false, 10, false)
        @provider.action_delete
      end
  
      it "should update the resource" do
        @new_resource.should_receive(:updated=).with(true)
        @provider.action_delete
      end
    end
  end
end
