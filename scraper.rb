#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(url)
  noko = noko_for(url)

  noko.css('#divmaincontent table').xpath('.//tr[contains(.,"Hon")]').each do |tr|
    tds = tr.css('td')

    prefix, name = tds[1].text.strip.split('Hon.')

    data = { 
      name: name.strip,
      honorifix_prefix: prefix.strip,
      constituency: tds[0].text.strip,
      party: 'New National Party', # https://en.wikipedia.org/wiki/Grenadian_general_election,_2013
      party_id: 'NNP',
      tel: tds[3].text.strip,
      term: '2013',
      source: url,
    }
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('http://www.gov.gd/contact_mp.html')