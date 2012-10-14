require 'test_helper'
require 'md2man/html/engine'

describe Md2Man::HTML do
  before do
    @markdown = Redcarpet::Markdown.new(
      Md2Man::HTML::Engine,
      :tables => true,
      :autolink => true,
    )
  end

  def heredoc document
    document.gsub(/^\s*\|/, '').chomp
  end

  it 'renders nothing as nothing' do
    @markdown.render('').must_be_empty
  end

  it 'renders paragraphs' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4-space indent
    INPUT
      |<p>just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4-space indent</p>
    OUTPUT
  end

  it 'renders tagged paragraphs with uniformly two-space indented bodies' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some paragraph
      |  spanning
      |  multiple
      |  lines
      |  but within 4-space indent
      |
      |  and a single line following
      |
      |  and multiple
      |  lines following
    INPUT
      |<dl><dt>just some paragraph</dt><dd>spanning
      |multiple
      |lines
      |but within 4-space indent</dd></dl><dl><dd>and a single line following</dd></dl><dl><dd>and multiple
      |lines following</dd></dl>
    OUTPUT
  end

  it 'renders references to other man pages as hyperlinks in middle of line' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |convert them from markdown(7) into roff(7), using
    INPUT
      |<p>convert them from <a class="manpage-reference" href="../man7/markdown.7.html">markdown(7)</a> into <a class="manpage-reference" href="../man7/roff.7.html">roff(7)</a>, using</p>
    OUTPUT
  end

  it 'renders references to other man pages as hyperlinks at beginning of line' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |markdown(1) into roff(2)
    INPUT
      |<p><a class="manpage-reference" href="../man1/markdown.1.html">markdown(1)</a> into <a class="manpage-reference" href="../man2/roff.2.html">roff(2)</a></p>
    OUTPUT
  end

  it 'does not render references inside code blocks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    this is a code block
      |    containing markdown(7),
      |    roff(7), and much more!
    INPUT
      |<pre><code>this is a code block
      |containing markdown(7),
      |roff(7), and much more!
      |</code></pre>
    OUTPUT
  end

  it 'does not render references inside code spans' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |this is a code span `containing markdown(7), roff(7), and` much more!
    INPUT
      |<p>this is a code span <code>containing markdown(7), roff(7), and</code> much more!</p>
    OUTPUT
  end

  it 'escapes backslashes inside code blocks' do
    # NOTE: we have to escape backslashes in the INPUT to
    #       prevent Ruby from interpreting them as escapes
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    _______      _______
      |     ___  /___________ /__
      |      _  __/ __ \\  __/ /_/
      |      / /_/ /_/ / / / ,\\
      |      \\__/\\____/_/ /_/|_\\
      |                 >>>------>
    INPUT
      |<pre><code>_______      _______
      | ___  /___________ /__
      |  _  __/ __ \\  __/ /_/
      |  / /_/ /_/ / / / ,\\
      |  \\__/\\____/_/ /_/|_\\
      |             &gt;&gt;&gt;------&gt;
      |</code></pre>
    OUTPUT
  end
end
