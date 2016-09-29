module Jekyll
  module Paginate
    class Pagination < Generator
      # This generator is safe from arbitrary code execution.
      safe true

      # This generator should be passive with regard to its execution
      priority :lowest

      # Generate paginated pages if necessary.
      #
      # site - The Site.
      #
      # Returns nothing.
      def generate(site)
        if Pager.pagination_customization_enabled?(site)
          site.config['paginate_paths'].each do | paginate_type, paginate_path |
            if template = self.class.template_page(site, paginate_path)
              paginate(site, template, paginate_type)
            else
              Jekyll.logger.warn "Pagination:", "Pagination is enabled, but I couldn't find " +
              "an index.html page to use as the pagination template. Skipping pagination."
            end
          end
        elsif Pager.pagination_enabled?(site)
          if template = self.class.template_page(site, site.config['paginate_path'])
            paginate(site, template)
          else
            Jekyll.logger.warn "Pagination:", "Pagination is enabled, but I couldn't find " +
            "an index.html page to use as the pagination template. Skipping pagination."
          end
        end
      end

      # Paginates the blog's posts. Renders the index.html file into paginated
      # directories, e.g.: page2/index.html, page3/index.html, etc and adds more
      # site-wide data.
      #
      # site          - The Site.
      # page          - The index.html Page that requires pagination.
      # paginate_type - The type of pagination if pagination is customizable
      #
      # {"paginator" => { "page" => <Number>,
      #                   "per_page" => <Number>,
      #                   "posts" => [<Post>],
      #                   "total_posts" => <Number>,
      #                   "total_pages" => <Number>,
      #                   "previous_page" => <Number>,
      #                   "next_page" => <Number> }}
      def paginate(site, page, paginate_type = nil)
        if !paginate_type
          all_posts = site.site_payload['site']['posts'].reject { |post| post['hidden'] }
        else
          all_posts = site.site_payload['site']['categories'][paginate_type].reject { |post| post['hidden'] }
        end
        pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)
        (1..pages).each do |num_page|
          pager = Pager.new(site, num_page, all_posts, pages, paginate_type)
          if num_page > 1
            newpage = Page.new(site, site.source, page.dir, page.name)
            newpage.pager = pager
            newpage.dir = Pager.paginate_path(site, num_page, paginate_type)
            site.pages << newpage
          else
            page.pager = pager
          end
        end
      end

      # Static: Fetch the URL of the template page. Used to determine the
      #         path to the first pager in the series.
      #
      # site          - the Jekyll::Site object
      # paginate_type - The type of pagination if pagination is customizable
      #
      # Returns the url of the template page
      def self.first_page_url(site, paginate_type)
        paginate_path = paginate_type ? site.config['paginate_paths'][paginate_type] : site.config['paginate_path']

        if page = Pagination.template_page(site, paginate_path)
          page.url
        else
          nil
        end
      end

      # Public: Find the Jekyll::Page which will act as the pager template
      #
      # site - the Jekyll::Site object
      # paginate_path - the absolute paginate path (from root of FS)
      #
      # Returns the Jekyll::Page which will act as the pager template
      def self.template_page(site, paginate_path)
        site.pages.select do |page|
          Pager.pagination_candidate?(site.config, page, paginate_path)
        end.sort do |one, two|
          two.path.size <=> one.path.size
        end.first
      end

    end
  end
end
