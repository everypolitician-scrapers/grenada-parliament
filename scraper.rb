#!/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'pry'
require 'scraperwiki'

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
    puts data.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h if ENV['MORPH_DEBUG']
    ScraperWiki.save_sqlite(%i[name term], data)
  end
end

scrape_list('https://www.gov.gd/contact_mp.html')
