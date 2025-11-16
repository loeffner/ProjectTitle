local BD = require("ui/bidi")
local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local FileManagerBookInfo = require("apps/filemanager/filemanagerbookinfo")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local FrameContainer = require("ui/widget/container/framecontainer")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local ImageWidget = require("ui/widget/imagewidget")
local LeftContainer = require("ui/widget/container/leftcontainer")
local LineWidget = require("ui/widget/linewidget")
local ProgressWidget = require("ui/widget/progresswidget")
local RenderImage = require("ui/renderimage")
local Size = require("ui/size")
local ScrollHtmlWidget = require("ui/widget/scrollhtmlwidget")
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local TitleBar = require("ui/widget/titlebar")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local logger = require("logger")
local util = require("util")
local _ = require("l10n.gettext")
local Screen = Device.screen
local T = require("ffi/util").template
local BookInfoManager = require("bookinfomanager")
local ptutil = require("ptutil")
local ptdbg = require("ptdbg")

local AltBookStatusWidget = {}

function AltBookStatusWidget:getStatusContent(width)
    local title_bar = TitleBar:new {
        width = width,
        bottom_v_padding = 0,
        close_callback = not self.readonly and function() self:onClose() end,
        show_parent = self,
    }
    local read_percentage = self.ui:getCurrentPage() / self.total_pages
    local content = VerticalGroup:new {
        align = "left",
        title_bar,
        self:genBookInfoGroup(),
        self:genHeader(_("Progress") .. ": " .. string.format("%1.f%%", read_percentage * 100)),
        self:genStatisticsGroup(width),
        self:genHeader(_("Description")),
        self:genSummaryGroup(width),
    }
    return content
end

function AltBookStatusWidget:genHeader(title)
    local width, height = Screen:getWidth(), Size.item.height_default

    local header_title = TextWidget:new {
        text = title,
        face = Font:getFace(ptutil.good_sans, ptutil.bookstatus_defaults.header_font_size),
        fgcolor = Blitbuffer.COLOR_GRAY_9,
    }

    local padding_span = HorizontalSpan:new { width = self.padding }
    local line_width = (width - header_title:getSize().w) / 2 - self.padding * 2
    local line_container = LeftContainer:new {
        dimen = Geom:new { w = line_width, h = height },
        LineWidget:new {
            background = Blitbuffer.COLOR_LIGHT_GRAY,
            dimen = Geom:new {
                w = line_width,
                h = Size.line.thick,
            }
        }
    }
    local span_top, span_bottom
    if Screen:getScreenMode() == "landscape" then
        span_top = VerticalSpan:new { width = Size.span.horizontal_default }
        span_bottom = VerticalSpan:new { width = Size.span.horizontal_default }
    else
        span_top = VerticalSpan:new { width = Size.item.height_default }
        span_bottom = VerticalSpan:new { width = Size.span.vertical_large }
    end

    return VerticalGroup:new {
        span_top,
        HorizontalGroup:new {
            align = "center",
            padding_span,
            line_container,
            padding_span,
            header_title,
            padding_span,
            line_container,
            padding_span,
        },
        span_bottom,
    }
end

function AltBookStatusWidget:genBookInfoGroup()
    -- override the original fonts with our included fonts
    self.small_font_face = Font:getFace(ptutil.good_serif, ptutil.bookstatus_defaults.small_font_size)
    self.medium_font_face = Font:getFace(ptutil.good_serif, ptutil.bookstatus_defaults.medium_font_face)
    self.large_font_face = Font:getFace(ptutil.good_serif, ptutil.bookstatus_defaults.large_font_face)

    -- padding to match the width used in cover list and grid
    self.padding = Screen:scaleBySize(10)

    local screen_width = Screen:getWidth()
    local split_span_width = math.floor(screen_width * 0.05)

    local img_width, img_height
    if Screen:getScreenMode() == "landscape" then
        img_width = Screen:scaleBySize(132)
        img_height = Screen:scaleBySize(184)
    else
        img_width = Screen:scaleBySize(132 * 1.5)
        img_height = Screen:scaleBySize(184 * 1.5)
    end

    local height = img_height
    local width = screen_width - split_span_width - img_width

    -- Get a chance to have title and authors rendered with alternate
    -- glyphs for the book language
    local props = self.ui.doc_props
    local lang = props.language

    -- author(s) text
    local authors = ""
    if props.authors then
        authors = ptutil.formatAuthors(props.authors, 2)
    end

    -- series name and position (if available, if requested)
    local series_mode = BookInfoManager:getSetting("series_mode")
    local show_series = props.series and props.series_index
    local series
    if show_series then
        series = ptutil.formatSeries(props.series, props.series_index)
        -- if series comes back as blank, don't include it
        if series == "" then show_series = false end
    else
        series = ""
    end

    -- combine author and series
    local author_series_text = ptutil.formatAuthorSeries(authors, series, series_mode, false)

    -- author(s) and series combined box
    local author_series = TextBoxWidget:new {
        text = author_series_text,
        lang = lang,
        face = Font:getFace(ptutil.good_serif, ptutil.bookstatus_defaults.small_serif_size),
        width = width,
        alignment = "center",
        fgcolor = Blitbuffer.COLOR_GRAY_2,
    }

    -- progress bar
    local read_percentage = self.ui:getCurrentPage() / self.total_pages
    local progress_bar = ProgressWidget:new {
        width = math.floor(width * 0.7),
        height = Screen:scaleBySize(18),
        percentage = read_percentage,
        margin_v = 0,
        margin_h = 0,
        bordersize = Screen:scaleBySize(0.5),
        bordercolor = Blitbuffer.COLOR_BLACK,
        bgcolor = Blitbuffer.COLOR_GRAY_E,
        fillcolor = Blitbuffer.COLOR_GRAY_6,
    }

    -- current chapter title, if available
    local book_chapter = self.ui.toc:getTocTitleByPage(self.ui:getCurrentPage()) or ""
    local chapter_title = TextWidget:new {
        text = book_chapter,
        lang = lang,
        face = Font:getFace(ptutil.good_serif_it, ptutil.bookstatus_defaults.small_serif_size),
        width = width,
        alignment = "center",
        fgcolor = Blitbuffer.COLOR_BLACK,
    }

    -- title box (done last to calculate the max available height)
    local max_title_height = height - author_series:getSize().h - progress_bar:getSize().h - chapter_title:getSize().h - Size.padding.default
    local book_title = TextBoxWidget:new {
        text = props.display_title,
        lang = lang,
        width = width,
        height = max_title_height,
        height_adjust = true,
        height_overflow_show_ellipsis = true,
        face = Font:getFace(ptutil.title_serif, ptutil.bookstatus_defaults.large_serif_size),
        alignment = "center",
    }

    -- padding
    local meta_padding_height = math.max(Size.padding.default, height - book_title:getSize().h - author_series:getSize().h - progress_bar:getSize().h - chapter_title:getSize().h)
    local meta_padding = VerticalSpan:new { width = meta_padding_height }

    -- horizontal dividing line
    local book_meta_line = LineWidget:new {
        background = Blitbuffer.COLOR_LIGHT_GRAY,
        dimen = Geom:new {
            w = width * 0.2,
            h = Size.line.thick,
        }
    }

    -- build metadata column (adjacent to cover)
    local book_meta_info_group = VerticalGroup:new {
        align = "center",
    }
    table.insert(book_meta_info_group, book_title)
    table.insert(book_meta_info_group, book_meta_line)
    if book_chapter ~= "" then
        table.insert(book_meta_info_group,
            CenterContainer:new {
                dimen = Geom:new { w = width, h = chapter_title:getSize().h },
                chapter_title
            }
        )
        table.insert(book_meta_info_group, book_meta_line)
    end
    table.insert(book_meta_info_group,
        CenterContainer:new {
            dimen = Geom:new { w = width, h = author_series:getSize().h },
            author_series
        }
    )
    table.insert(book_meta_info_group, meta_padding)
    table.insert(book_meta_info_group,
        CenterContainer:new {
            dimen = Geom:new { w = width, h = progress_bar:getSize().h },
            progress_bar
        }
    )

    -- assemble the final row w/ cover and metadata [X|Y]
    local book_info_group = HorizontalGroup:new {
        align = "top",
        HorizontalSpan:new { width = split_span_width }
    }
    -- cover column
    local thumbnail = FileManagerBookInfo:getCoverImage(self.ui.document)
    if thumbnail then
        -- Much like BookInfoManager, honor AR here
        local cbb_w, cbb_h = thumbnail:getWidth(), thumbnail:getHeight()
        if cbb_w > img_width or cbb_h > img_height then
            local scale_factor = math.min(img_width / cbb_w, img_height / cbb_h)
            cbb_w = math.min(math.floor(cbb_w * scale_factor) + 1, img_width)
            cbb_h = math.min(math.floor(cbb_h * scale_factor) + 1, img_height)
            thumbnail = RenderImage:scaleBlitBuffer(thumbnail, cbb_w, cbb_h, true)
        end
        local border_total = Size.border.thin * 2
        local dimen = Geom:new {
            w = cbb_w + border_total,
            h = cbb_h + border_total,
        }
        local image = ImageWidget:new {
            image = thumbnail,
            width = cbb_w,
            height = cbb_h,
        }
        table.insert(book_info_group, CenterContainer:new {
            dimen = dimen,
            FrameContainer:new {
                width = dimen.w,
                height = dimen.h,
                margin = 0,
                padding = 0,
                radius = Size.radius.default,
                bordersize = Size.border.thin,
                dim = self.file_deleted,
                color = Blitbuffer.COLOR_GRAY_3,
                image,
            }
        })
    end
    -- metadata column
    table.insert(book_info_group, CenterContainer:new {
        dimen = Geom:new { w = width, h = height },
        book_meta_info_group,
    })

    return CenterContainer:new {
        dimen = Geom:new { w = screen_width, h = img_height },
        book_info_group,
    }
end

function AltBookStatusWidget:genSummaryGroup(width)
    local height
    if Screen:getScreenMode() == "landscape" then
        height = Screen:scaleBySize(165)
    else
        height = Screen:scaleBySize(265)
    end

    local html_contents = ""
    local props = self.ui.doc_props
    if props.description then
        html_contents = "<html lang='" .. props.language .. "'><body>" .. props.description .. "</body></html>"
    else
        html_contents = "<html><body><h3 style='font-style: italic; color: #CCCCCC;'>" ..
        _("No book description available.") .. "</h3></body></html>"
    end
    self.input_note = ScrollHtmlWidget:new {
        width = width - Screen:scaleBySize(60),
        height = height,
        css = [[
            @page {
                margin: 0;
                font-family: 'Source Serif 4', serif;
                font-size: 18px;
                line-height: 1.00;
                text-align: justify;
            }
            body {
                margin: 0;
                padding: 0;
            }
            p {
                margin-top: 0;
                margin-bottom: 0;
                text-indent: 1.2em;
            }
            p + p {
                margin-top: 0.5em;
            }
        ]],
        default_font_size = Screen:scaleBySize(18),
        html_body = html_contents,
        text_scroll_span = Screen:scaleBySize(20),
        scroll_bar_width = Screen:scaleBySize(10),
        dialog = self,
    }
    table.insert(self.layout, { self.input_note })

    return VerticalGroup:new {
        VerticalSpan:new { width = Size.span.vertical_large },
        CenterContainer:new {
            dimen = Geom:new { w = width, h = height },
            self.input_note
        }
    }
end

return AltBookStatusWidget
