import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getAccountWithLayership from '@salesforce/apex/AccountLayerShipController.getAccountWithLayership';
import g6_358 from '@salesforce/resourceUrl/g6_358';

export default class accountLayershipG6Graph extends LightningElement {
 	@api accountId;
    @api flexipageRegionWidth;

    clickedNodeId;

    @api
    reRenderGraph() {
        getAccountWithLayership({
            accountId: this.accountId
        })
        .then(result => {
            console.log("重新渲染树了");
            console.log('result===' + result);
            if (result) {
                const initData = this.handleGraphData(result);
                this.graph.changeData(initData);

            } else {
                console.log('no record');
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '获取关系数据出错',
                    message: error.message || '未知错误',
                    variant: 'error'
                })
            );
        });
    }

    g6Initialized = false;
    graph;

    currentNode;
    docScrollTop = 0;
    docScrollLeft = 0;
    canvasDomSize = [940, 680];
    commonStyle = {
        fontFamily: `'Arial Normal', 'Arial', sans-serif`,
        fontWeight: 400,
    }

    connectedCallback() {
        window.addEventListener('scroll', () => {
            this.docScrollTop = document.documentElement.scrollTop || document.body.scrollTop || window.pageYOffset;
            this.docScrollLeft = document.documentElement.scrollLeft || document.body.scrollLeft || window.pageXOffset;
        })
    }

    add(){
        this.dispatchEvent(new CustomEvent('addcontact',{detail:{currentNodeRecordId:this.currentNode.getModel().id}}));
    }

    get showRemoveButton(){
        if(this.currentNode && this.currentNode.getModel().id.startsWith('001')){
            return false;
        } else {
            return true;
        }
    }

    remove(){
        this.dispatchEvent(new CustomEvent('removecontact',{detail:{currentNodeRecordId:this.currentNode.getModel().id}}));
    }

    renderedCallback() {
        if (this.g6Initialized) {
            return;
        }
        this.g6Initialized = true;

        Promise.all([
            loadScript(this, g6_358 + '/g6.min.js')
        ])
            .then(() => {
                this.initG6graph();
                this.initializeG6Data();
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading G6',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    // getPosition(element) {
    //     return $(element).offset();
    // }

    initializeG6Data() {

        getAccountWithLayership({
            accountId: this.accountId
        })
        .then(result => {
            if (result) {
                console.log('result====' + result);
                const initData = this.handleGraphData(result);
                console.log('回来了');
                this.graph.data(initData); // 读取 Step 2 中的数据源到图上
                this.graph.render(); // 渲染图
                this.graph.translate(0, -58); // 向上移动 50像素

            } else {
                console.log('no record');
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '获取关系数据出错',
                    message: error.message || '未知错误',
                    variant: 'error'
                })
            );
        });
    }

    // initG6graph() {
        
    //     G6.registerNode(
    //         'structNode',
    //         {
    //             draw(cfg, group) {
    //                 const TitleHeight = 24;  // 标题的高度
    //                 const TextHeight = 18;  // 内容的行高
    //                 const headFS = 14;  // 头部字体的大小
    //                 const size = this.getSize(cfg);
    //                 const width = size[0];
    //                 const height = size[1];
    //                 const style = cfg.style;

    //                 let keyShape;
    //                 keyShape = group.addShape('rect', {
    //                     attrs: {
    //                         x: 0,
    //                         y: 0,
    //                         width,
    //                         height,
    //                         ...style,  // 外盒子的样式
    //                     }
    //                 });
    //                 group.addShape('rect', {
    //                     attrs: {
    //                         x: 0,
    //                         y: 0,
    //                         width,
    //                         height: TitleHeight,
    //                         fill: '#fff',
    //                         stroke: style.stroke, // 描边颜色
    //                         lineWidth: style.lineWidth,
    //                     }
    //                 })
    //                 group.addShape('text', {
    //                     attrs: {
    //                         x: width / 2, // 居中
    //                         y: TitleHeight / 2 + 1,
    //                         text: cfg.title,
    //                         textAlign: 'center',
    //                         textBaseline: 'middle',
    //                         fill: '#333',
    //                         fontSize: headFS,
    //                         ...this.commonStyle,
    //                     }
    //                 })
    //                 let lineData = cfg.lineData ? cfg.lineData : [];
    //                 const firstY = TitleHeight + 12;
    //                 lineData.forEach((item, index) => {
    //                     group.addShape('text', {
    //                         attrs: {
    //                             vType: 'content-text',
    //                             x: width / 2, // 水平居中
    //                             y: firstY + (TextHeight + 0) * index,  // 0为两行文字的间距
    //                             lineHeight: TextHeight,
    //                             text: item,
    //                             textAlign: 'center',
    //                             lineHeight: TextHeight,
    //                             textBaseline: 'top',
    //                             fill: '#fff',
    //                             fontSize: 11,
    //                             ...this.commonStyle,
    //                         }
    //                     })
    //                 })
    //                 // 返回 keyShape
    //                 return keyShape;
    //             },
    //             setState(name, value, item) {
    //                 if (name === 'isClick') {
    //                     const group = item.getContainer(); // 获取容器

    //                 }
    //             },
    //             anchor: [
    //                 [0, 0.5], // 左中
    //                 [1, 0.5], // 右中
    //                 [0.5, 0], // 上中
    //                 [0.5, 1]  // 下中
    //             ],
    //         },
    //         // 注意这里继承了 'single-node'
    //         'single-node',
    //     );

    //     this.graph = new G6.Graph({
    //         container: this.template.querySelector('[data-id="mountNode"]'), // String | HTMLElement，必须
    //         width: this.canvasDomSize[0], // Number，必须，图的宽度 1190
    //         height: this.canvasDomSize[1], // Number，必须，图的高度
    //         center: [0, 0],
    //         layout: {
    //             type: 'dagre',
    //             nodesep: 36, // 节点间距
    //             ranksep: 25, // 层间距
    //             preventOverlap: true,
    //         },
    //         defaultNode: {
    //             type: 'rect',
    //             //size: [232, 142],
    //             size: [186, 114],
    //             style: {
    //                 fill: 'rgb(34, 94, 172)',
    //                 stroke: 'rgb(121, 121, 121)', // 描边颜色
    //                 lineWidth: 1,
    //                 shadowOffsetY: 2,
    //                 shadowBlur: 6,
    //                 endArrow: true,
    //                 startArrow: true
    //             },
    //             anchorPoints: [
    //                 [0.5, 0],
    //                 [0.5, 1],
    //             ],
    //         },
    //         defaultEdge: {
    //             shape: 'polyline',
    //             style: {
    //                 offset: 35,  // 拐弯处距离节点最小距离
    //                 lineWidth: 1,
    //                 stroke: 'rgb(121, 121, 121)',
    //             }
    //         },
    //         // 内置交互
    //         modes: {
    //             default: ['drag-canvas', /*'zoom-canvas', 'drag-node' */]  // 允许拖拽画布、放缩画布、拖拽节点
    //         },
    //         nodeStateStyles: {
    //             click: {
    //                 stroke: '#000',
    //                 lineWidth: 20
    //             }
    //         },
    //     });

    //     this.graph.on('node:mouseenter', evt => {
    //         const { item } = evt;
    //         evt.preventDefault();
    //         evt.stopPropagation();
    //         let { x, y, width } = item.getBBox();  // x, y为视口坐标

    //         console.log(x);
    //         console.log(y);
    //         console.log(width);
    //         let pagePoint = this.graph.getClientByPoint(x + width, y); // 获取屏幕/页面坐标
    //         console.log('mouse enter');
    //         if ((pagePoint.x) <= this.canvasDomSize[0]) {
    //            console.log(this.docScrollTop);
    //            console.log(this.docScrollLeft);
    //            console.log(pagePoint);
    //             console.log(this.template.querySelector('[data-id="mountNode"]').scrollLeft);
    //             console.log(document.documentElement.scrollLeft);
    //             console.log(document.documentElement.scrollTop);
    //             this.template.querySelector('[data-id="actions"]').style.display = 'block';
    //             this.template.querySelector('[data-id="actions"]').style.top = `${pagePoint.y + this.docScrollTop - 340}px`;
    //             this.template.querySelector('[data-id="actions"]').style.left = `${pagePoint.x + this.docScrollLeft - 30}px`;
    //             console.log('mouse enter style');
    //             this.currentNode = item;
    //         }
    //     });

    //     this.graph.on('node:mouseleave', evt => {
    //         this.template.querySelector('[data-id="actions"]').style.display = 'none';
    //     });
        
    // }

 initG6graph() {
        const mountNodeRef = this.template.querySelector('[data-id="mountNode"]');
        G6.registerNode(
            'structNode',
            {
                draw(cfg, group) {
                    const TitleHeight = 24;  // 标题的高度
                    const TextHeight = 18;  // 内容的行高
                    const headFS = 14;  // 头部字体的大小
                    const size = this.getSize(cfg);
                    const width = size[0];
                    const height = size[1];
                    const style = cfg.style;
                    /**tri add 2020-9-15 */
                    const headSlices = fittingString(cfg.title, width, headFS);
                    const TitleHeightFinally = TitleHeight * headSlices.length;
                    let mainBoxHeight = height;
                    if (headSlices.length > 1) {
                        mainBoxHeight = height + (headSlices.length - 1) * TitleHeight
                    }
                    /**tri add 2020-9-15 end*/
                    let keyShape;
                    keyShape = group.addShape('rect', {
                        attrs: {
                            x: 0,
                            y: 0,
                            width,
                            height: mainBoxHeight,
                            ...style,  // 外盒子的样式
                        }
                    });
                    group.addShape('rect', {
                        attrs: {
                            x: 0,
                            y: 0,
                            width,
                            height: TitleHeightFinally,
                            fill: '#fff',
                            stroke: style.stroke, // 描边颜色
                            lineWidth: style.lineWidth,
                        }
                    })
                    /**tri add 2020-9-15 */
                    headSlices.forEach((headSlice, index) => {
                        group.addShape('text', {
                          attrs: {
                            x: width / 2, // 居中
                            y: index * TitleHeight + TitleHeight / 2 + 1,
                            //text: cfg.title,
                            text: headSlices[index],
                            textAlign: 'center',
                            textBaseline: 'middle',
                            fill: '#333',
                            fontSize: headFS,
                            ...this.commonStyle,
                          }
                        })
                    })
                    /**tri add 2020-9-15 end*/
                    /* tri hide 2020-9-15
                    group.addShape('text', {
                        attrs: {
                            x: width / 2, // 居中
                            y: TitleHeight / 2 + 1,
                            text: cfg.title,
                            textAlign: 'center',
                            textBaseline: 'middle',
                            fill: '#333',
                            fontSize: headFS,
                            ...this.commonStyle,
                        }
                    })*/
                    let lineData = cfg.lineData ? cfg.lineData : [];
                    const firstY = TitleHeightFinally + 12;
                    lineData.forEach((item, index) => {
                        group.addShape('text', {
                            attrs: {
                                vType: 'content-text',
                                x: width / 2, // 水平居中
                                y: firstY + (TextHeight + 0) * index,  // 0为两行文字的间距
                                lineHeight: TextHeight,
                                //text: item,
                                text: fittingStringSingleLine(item, width - 8, 11),
                                textAlign: 'center',
                                lineHeight: TextHeight,
                                textBaseline: 'top',
                                fill: '#fff',
                                fontSize: 11,
                                ...this.commonStyle,
                            }
                        })
                    })
                    // 返回 keyShape
                    return keyShape;
                },
                setState(name, value, item) {
                    if (name === 'isClick') {
                        const group = item.getContainer(); // 获取容器

                    }
                },
                anchor: [
                    [0, 0.5], // 左中
                    [1, 0.5], // 右中
                    [0.5, 0], // 上中
                    [0.5, 1]  // 下中
                ],
            },
            // 注意这里继承了 'single-node'
            'single-node',
        );

        this.graph = new G6.Graph({
            container: this.template.querySelector('[data-id="mountNode"]'), // String | HTMLElement，必须
            width: this.canvasDomSize[0], // Number，必须，图的宽度 1190
            height: this.canvasDomSize[1], // Number，必须，图的高度
            // fitView: true,
            // fitViewPadding: [20],
            // center: [0, 0],
            layout: {
                type: 'dagre',
                nodesep: 36, // 节点间距
                ranksep: 25, // 层间距
                preventOverlap: true,
            },
            defaultNode: {
                type: 'rect',
                //size: [232, 142],
                size: [186, 114],
                style: {
                    fill: 'rgb(34, 94, 172)',
                    stroke: 'rgb(121, 121, 121)', // 描边颜色
                    lineWidth: 1,
                    shadowOffsetY: 2,
                    shadowBlur: 6,
                    endArrow: true,
                    startArrow: true
                },
                anchorPoints: [
                    [0.5, 0],
                    [0.5, 1],
                ],
            },
            defaultEdge: {
                shape: 'polyline',
                style: {
                    offset: 35,  // 拐弯处距离节点最小距离
                    lineWidth: 1,
                    stroke: 'rgb(121, 121, 121)',
                }
            },
            // 内置交互
            modes: {
                default: ['drag-canvas',/* 'zoom-canvas', 'drag-node' */]  // 允许拖拽画布、放缩画布、拖拽节点
            },
            nodeStateStyles: {
                click: {
                    stroke: '#000',
                    lineWidth: 20
                }
            },
        });

        this.graph.on('node:mouseenter', evt => {
            const { item } = evt;
            evt.preventDefault();
            evt.stopPropagation();
            let { x, y, width } = item.getBBox();  // x, y为视口坐标

            console.log(x);
            console.log(y);
            console.log(width);
            let pagePoint = this.graph.getClientByPoint(x + width, y); // 获取屏幕/页面坐标
            console.log('mouse enter');
            if ((pagePoint.x) <= this.canvasDomSize[0]) {
               console.log(this.docScrollTop);
               console.log(this.docScrollLeft);
               console.log(pagePoint);
                console.log(this.template.querySelector('[data-id="mountNode"]').scrollLeft);
                console.log(document.documentElement.scrollLeft);
                console.log(document.documentElement.scrollTop);
                this.template.querySelector('[data-id="actions"]').style.display = 'block';
                this.template.querySelector('[data-id="actions"]').style.top = `${pagePoint.y + this.docScrollTop - 340}px`;
                this.template.querySelector('[data-id="actions"]').style.left = `${pagePoint.x + this.docScrollLeft - 30}px`;
                console.log('mouse enter style');
                this.currentNode = item;
            }
        });

        this.graph.on('node:mouseleave', evt => {
            this.template.querySelector('[data-id="actions"]').style.display = 'none';
        });
        // this.graph.on('afterlayout', () => {
        //     console.log("after layout .");
        //     this.setNodeBoundary(this.graph);
        // });
    }
    handleGraphData(result){
        let nodes = [];
        //const acc = result.acc;
        const parentContactsWithMembership = result.parentAccountLayerShip;
        const parentContactsWithMembershipChildrenMap = result.parentAccountLayerShipChildrenMap;


        this.pushContactNodes(parentContactsWithMembership, parentContactsWithMembershipChildrenMap, nodes);

        let edges = [];
        parentContactsWithMembership.forEach((con)=>{
            edges.push({
                source: con.Id,
                target: con.Id
            });
            this.pushContactEdges(con, parentContactsWithMembershipChildrenMap, edges);
        });

        return { nodes: nodes, edges: edges };
    }

    pushContactNodes(contacts, contactsMap, nodes) {
        contacts.forEach((con) => {
            nodes.push({
                id: con.Id,
                title: con.Name,
                shape: "structNode",
                lineData: [
                    // '负责人:' + con.Owner.Name,
                    '客户分类：' + (con.Accounttype__c || ''),
                    '战区：' + (con.Region__c || '')
                    
                ]
            });

            if (contactsMap[con.Id]) {
                this.pushContactNodes(contactsMap[con.Id], contactsMap, nodes)
            }
        });
    }

    pushContactEdges(contact, contactsMap, edges) {
        if (contactsMap[contact.Id]) {
            contactsMap[contact.Id].forEach((childCon)=>{
                edges.push({
                    source: contact.Id,
                    target: childCon.Id
                });
                this.pushContactEdges(childCon, contactsMap, edges);
            });
        }
    }
}

const fittingString = (str, maxWidth, fontSize) =>{
    str = str.replace('\n','');
    let currentWidth = 0;
    let res = str;
    const pattern = new RegExp("[\u4E00-\u9FA5]+"); // distinguish the Chinese charactors and letters
    str.split('').forEach((letter, i) =>{
        if (currentWidth > maxWidth) return;
        if (pattern.test(letter)) {
            // Chinese charactors
            currentWidth += fontSize;
        } else {
            // get the width of single letter according to the fontSize
            currentWidth += G6.Util.getLetterWidth(letter, fontSize);
        }
        if (currentWidth > maxWidth) {
            res = `${str.substr(0, i)}\n${str.substr(i)}`;
        }
    });
    return res.split("\n");
};

const fittingStringSingleLine = (str, maxWidth, fontSize) => {
    const ellipsis = '...';
    const ellipsisLength = G6.Util.getTextSize(ellipsis, fontSize)[0];
    let currentWidth = 0;
    let res = str;
    const pattern = new RegExp('[\u4E00-\u9FA5]+'); // distinguish the Chinese charactors and letters
    str.split('').forEach((letter, i) => {
      if (currentWidth > maxWidth - ellipsisLength) return;
      if (pattern.test(letter)) {
        // Chinese charactors
        currentWidth += fontSize;
      } else {
        // get the width of single letter according to the fontSize
        currentWidth += G6.Util.getLetterWidth(letter, fontSize);
      }
      if (currentWidth > maxWidth - ellipsisLength) {
        res = `${str.substr(0, i)}${ellipsis}`;
      }
    });
    return res;
  };