/**Post to get List*/
function getDropDownList(element, url) {
    $(element).kendoDropDownList({
        dataTextField: "Text",
        dataValueField: "Value",
        dataSource: {
            transport: {
                read: {
                    type: "POST",
                    url: /Book/ + url,
                    dataType: "json"
                }
            }
        }
    });
}


/**kendo 格式 */
function kendoDefaultSetting() {


    $("#InsertBookAmount").kendoNumericTextBox({
        format: "##,#",
        min: 0
    });

    $("#InsertBookBoughtDate").kendoDatePicker({
        format: "yyyy/MM/dd",
        dateInput: true,
        max: Date(),
        value: kendo.toString(new Date(), "yyyy/MM/dd")
    });


    $("#UpdateBookAmount").kendoNumericTextBox({
        format: "##,#",
        min: 0
    });

    $("#UpdateBookBoughtDate").kendoDatePicker({
        format: "yyyy/MM/dd",
        dateInput: true,
        max: Date(),
        value: kendo.toString(new Date(), "yyyy/MM/dd")
    });

}



/**kendo 驗證 */
var validatorOption = {
    messages: {
        cannotBeBlank: "欄位必填，不可輸入空白",
        BookNameValid: "超過400字數限制",
        BookAuthorValid: "超過60字數限制",
        BookPublisherValid: "超過40字數限制",
        BookNoteValid: "超過1200字數限制",
        BookBoughtDateValid: "請選擇日期，且日期不可超過今日",
    },
    rules: {
        cannotBeBlank: function (input) {
            if (input.is("[role!='spinbutton']")) {
                return $.trim(input.val()) != "";
            }
            return true;
        },

        //TODO :# 
        BookNameValid: function (input) {
            if (input.is("#InsertBookName") || input.is("#UpdateBookName")) {
                return input.val().length <= 400;
            }
            return true;
        },
        BookAuthorValid: function (input) {
            if (input.is("#InsertBookAuthor") || input.is("#UpdateBookAuthor")) {
                return input.val().length <= 60;
            }
            return true;
        },
        BookPublisherValid: function (input) {
            if (input.is("#InsertBookPublisher") || input.is("#UpdateBookPublisher")) {
                return input.val().length <= 40;
            }
            return true;
        },
        BookNoteValid: function (input) {
            if (input.is("#InsertBookNote") || input.is("#UpdateBookNote")) {
                return input.val().length <= 1200;
            }
            return true;
        },
        BookBoughtDateValid: function (input) {
            if (input.is("#InsertBookBoughtDate") || input.is("#UpdateBookBoughtDate")) {
                let date = kendo.parseDate(input.val(), "yyyy/MM/dd");
                if (date == null || date > new Date()) {
                    return false
                }
            }
            return true;
        },
    }
};

/**
 * Book Note auto grow
 * @param {any} element
 */
function auto_grow(element) {

    let maxheight = 350;
    $(element).css("height", "auto");

    if ($(element).prop("scrollHeight") < maxheight) {
        $(element).attr("style",
            "height:" + $(element).prop("scrollHeight") + "px"
        )
    }
    else {
        $(element).attr("style",
            "height:" + maxheight + "px"
        )
    }

    $(element).on("input", function () {
        $(element).css("height", "auto");
        if ($(element).prop("scrollHeight") < maxheight) {
            $(element).css("height", $(element).prop("scrollHeight") + "px");
        }
        else {
            $(element).css("height", maxheight + "px");
        }
    });

}


/**
 * 跳到編輯頁面
 * @param {any} e
 */
function OpenUpdateWindow(e) {
    var grid = $("#book_grid").data("kendoGrid");
    var row = grid.dataItem(event.target.closest("tr"));
    getDropDownList("#UpdateBookClassId", "GetBookClassListData");
    getDropDownList("#UpdateKeeperId", "GetBookKeeperListData");
    getDropDownList("#UpdateBookStatusCode", "GetBookStatusListData");
    $("#UpdateWindow").data("kendoWindow").center().open();

    $.ajax({
        type: "POST",
        url: "/Book/BookDetailByID",
        data: "bookId=" + row.BookID,
        dataType: "json",
        success: function (response) {
            $("#UpdateBookName").val(response.BookName);
            $("#UpdateBookAuthor").val(response.BookAuthor);
            $("#UpdateBookPublisher").val(response.BookPublisher);
            $("#UpdateBookNote").val(response.BookNote);
            auto_grow("#UpdateBookNote");
            $("#UpdateBookBoughtDate").val(response.BookBoughtDate);
            $("#UpdateBookClassId").data("kendoDropDownList").value(response.BookClassID);
            $("#UpdateBookAmount").data("kendoNumericTextBox").value(response.BookAmount);
            $("#UpdateBookStatusCode").data("kendoDropDownList").value(response.BookStatus);
            $("#UpdateKeeperId").data("kendoDropDownList").value(response.KeeperId);
            statusChange();
        }
    });

    //畫面與資料載入完成後初始化關聯
    statusChange();

    //書籍狀態改變時事件
    $("#UpdateBookStatusCode").change(function () {
        statusChange();
    });

    var validatorUpdate = $("#UpdateWindow").kendoValidator(validatorOption).data("kendoValidator");

    $("#Save").on("click", function (e) {

        if (validatorUpdate.validate() && confirm("確定修改書籍?") ) {
            $.ajax({
                type: "POST",
                url: "/Book/UpdateBook",
                data: {
                    BookId: row.BookID,
                    BookName: $("#UpdateBookName").val(),
                    BookAuthor: $("#UpdateBookAuthor").val(),
                    BookPublisher: $("#UpdateBookPublisher").val(),
                    BookNote: $("#UpdateBookNote").val(),
                    BookBoughtDate: $("#UpdateBookBoughtDate").data("kendoDatePicker").value(),
                    BookClassId: $("#UpdateBookClassId").data("kendoDropDownList").value(),
                    BookAmount: $("#UpdateBookAmount").data("kendoNumericTextBox").value(),
                    BookStatus: $("#UpdateBookStatusCode").data("kendoDropDownList").value(),
                    KeeperId: $("#UpdateKeeperId").data("kendoDropDownList").value(),

                },
                dataType: "json",
                success: function (response) {
                    $("#book_grid").data("kendoGrid").dataSource.read();
                    alert("修改成功");
                }, error: function (error) {
                    alert("系統發生錯誤");
                }
                ,
                beforeSend: function () {
                    kendo.ui.progress($("#UpdateWindow"), true);
                },
                complete: function () {
                    kendo.ui.progress($("#UpdateWindow"), false);

                }
            });
        }
    });

    $("#Delete").on("click", function (e) {
        DeleteBook(e, row.BookID);
    });

}


/**控制keeper 選擇器 */
function statusChange() {

    let status = $("#UpdateBookStatusCode").data("kendoDropDownList").value();
    //可借出
    if (status === "A" || status === "U") {
        $("#UpdateKeeperId").data("kendoDropDownList").value("");
        $("#UpdateKeeperId").data("kendoDropDownList").enable(false);

    }
    //已借出
    else if (status === "B" || status === "C") {
        $("#UpdateKeeperId").data("kendoDropDownList").enable(true);
    }
}

/**
 * 跳到借閱紀錄
 * @param {any} e
 */
function OpenRecordWindow(e) {
    e.preventDefault();
    var grid = $("#book_grid").data("kendoGrid");
    var row = grid.dataItem(event.target.closest("tr"));
    var ID = row.BookID;
    $("#lendRecordWindow").data("kendoWindow").center().open();

    //內部grid
    $("#lend_grid").kendoGrid({
        dataSource: {
            transport: {
                read: {
                    url: "/Book/BookLendRecord",
                    type: "post",
                    dataType: "json",
                    data: { BookID: ID }
                }
            },
            pageSize: 10,
        },
        height: 550,
        sortable: true,
        pageable: {
            input: true,
            numeric: false
        },
        columns: [

            { field: "LendDate", title: "借閱日期", width: "15%" },
            { field: "KeeperId", title: "借閱人員編號", width: "15%" },
            { field: "UserEName", title: "英文姓名", width: "15%" },
            { field: "UserCName", title: "中文姓名", width: "15%" }

        ]
    })
}

/**
 * 刪除書本
 * @param {any} e
 */
function DeleteBook(e, bookID = "") {
    // ctrl r r
    var check = confirm('Make sure this record is deleted or not?');
    if (check) {
        if (bookID == "") {
            e.preventDefault();
            var grid = $("#book_grid").data("kendoGrid");
            var row = grid.dataItem(event.target.closest("tr"));
            var ID = row.BookID;
            var inputData = ID;
        }
        else {
            var inputData = bookID;
        }
        kendo.ui.progress($("#book_grid"), true);
        kendo.ui.progress($("#UpdateWindow"), true);
        $.ajax({

            type: "POST",
            url: "/Book/DeleteBook",
            data: "BookID=" + inputData,
            dataType: "json",
            success: function (response) {

                if (response == true) {
                    $("#book_name").data("kendoAutoComplete").dataSource.read();
                    alert("The book has been deleted");
                    if (bookID != "") {
                        $("#UpdateWindow").data("kendoWindow").close()
                    } 
                    $("#book_grid").data("kendoGrid").dataSource.read();
                } else {
                    alert("Book is on loan, please delete them when they are returned");
                }
            },
            error: function (error) {
                alert("System error");
            },
            beforeSend: function () {
                kendo.ui.progress($("#UpdateWindow"), true);
                kendo.ui.progress($("#book_grid"), true);

            },
            complete: function () {
                kendo.ui.progress($("#UpdateWindow"), false);
                kendo.ui.progress($("#book_grid"), false);

            }
        });
    }

}

/**
 * Open Detail Window
 */
function OpenDetailWindow() {
    var grid = $("#book_grid").data("kendoGrid");
    var row = grid.dataItem(event.target.closest("tr"));
    getDropDownList("#DetailBookClassId", "GetBookClassListData");
    getDropDownList("#DetailKeeperId", "GetBookKeeperListData");
    getDropDownList("#DetailBookStatusCode", "GetBookStatusListData");

    $("#DetailWindow").data("kendoWindow").center().open();

    $.ajax({
        type: "POST",
        url: "/Book/BookDetailByID",
        data: "bookId=" + row.BookID,
        dataType: "json",
        success: function (response) {
            $("#DetailBookName").val(response.BookName);
            $("#DetailBookAuthor").val(response.BookAuthor);
            $("#DetailBookPublisher").val(response.BookPublisher);
            $("#DetailBookNote").val(response.BookNote);
            auto_grow("#DetailBookNote");
            $("#DetailBookBoughtDate").val(response.BookBoughtDate);
            $("#DetailBookClassId").data("kendoDropDownList").value(response.BookClassID);
            $("#DetailBookAmount").val(response.BookAmount);
            $("#DetailBookStatusCode").data("kendoDropDownList").value(response.BookStatus);
            $("#DetailKeeperId").data("kendoDropDownList").value(response.KeeperId);
        },
        beforeSend: function () {
            kendo.ui.progress($("#DetialWindow"), true);
        },
        complete: function () {
            kendo.ui.progress($("#DetialWindow"), false);
        }
    });


}










